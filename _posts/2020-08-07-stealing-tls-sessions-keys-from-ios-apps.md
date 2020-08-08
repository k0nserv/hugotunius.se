---
layout: post
title: "Stealing TLS Session Keys from iOS Apps"
categories: security reverse-engineering frida ios privacy
date: 2020-08-07
description: >
  When apps don't respect system proxies more advanced methods are needed to
  intercept their HTTP traffic.
---

Some iOS apps ship their own HTTP and TLS stack instead of relying on Apple's `NSURLSession` or the lower level frameworks it relies on. There are many reasons to do this, but the most common one I've encountered is apps that use a shared core, typically written in C++, which is used in applications on different platforms. This poses a problem for anyone trying to snoop on the apps network traffic. Recently, I was investigating an app like this and found myself having to intercept its HTTP traffic.

Apps that rely on system libraries will respect any HTTP(s) proxies configure on the device. This can be used with tools like [mitmproxy](https://mitmproxy.org/), [burp suite](https://portswigger.net/burp), or [Charles](https://www.charlesproxy.com/) to intercept or even modify network traffic. Apps that use their own HTTP and TLS stack typically don't respect system proxies and their traffic is completely invisible to these tools. If you aren't attentive you can even miss the traffic altogether as I almost did.

## Finding the Traffic

My modus operandi is to start with mitmproxy or Burp Suite, but in this case doing so meant I missed all of the app's traffic. Luckily for me, it was obvious from the app's behaviour that it was doing some form of networking. To figure this out I reached for [Wireshark](https://www.wireshark.org/) to capture all the traffic on the device.

To capture traffic on a remote device we need to make it visible to Wireshark. Apple provides a utility called Remote Virtual Interface Tool, `rvictl` for short, which does just this. With `rvictl` we can create a virtual interface on a mac that will capture all packets sent by a mobile device attached via USB. To do this we first need to find the UUID of the device. It's available in Xcode under `Window > Device and Simulators` but can also be found with the `ideviceinfo` utility from [`libimobiledevice`](https://libimobiledevice.org/).

{% highlight bash %}
$ ideviceinfo | grep UniqueDeviceID
{% endhighlight %}

Now we can create a virtual interface for the device.


{% highlight bash %}
$ rvictl -s <UUID>
{% endhighlight %}


This will create a virtual network interface typically called `rvi0` which we can configure Wireshark to use. Mission accomplished, right? Not quite. While we are capturing the traffic, all HTTPS traffic from a custom stack will be encrypted and opaque to us. With DNS queries in the clear we get a few more clues. TLS also reveals a tiny bit of information but the majority of the traffic is hidden behind encryption.

## Cracking the Crypto

The specific app that I was looking at used [BoringSSL](https://github.com/google/boringssl) for TLS. After some Gooling, I found a [blog post](https://andydavies.me/blog/2019/12/12/capturing-and-decrypting-https-traffic-from-ios-apps/) by [Andy Davies](https://andydavies.me/) which described a method to dump the TLS sessions keys from BoringSSL. Andy's method relies on knowing a specific offset for the keylog callback function in the `SSL_CTX` struct and hooking `SSL_CTX_set_info_callback` to set this value.

I realised that all `SSL_CTX` are created via the [`SSL_CTX_new`](https://www.openssl.org/docs/manmaster/man3/SSL_CTX_new.html) function and that there's a dedicated function, [`SSL_CTX_set_keylog_callback`](https://www.openssl.org/docs/manmaster/man3/SSL_CTX_set_keylog_callback.html), for setting the keylog callback. With this knowledge we can hook `SSL_CTX_new` and get a pointer to every `SSL_CTX` from its return value. Then we can simply call `SSL_CTX_set_keylog_callback` directly without needing to rely on known offsets, which are brittle. I've created a [Frida Codeshare](https://codeshare.frida.re/@k0nserv/tls-keylogger/) that does this. This method relies on us being able to find pointers to the two functions `SSL_CTX_new` and `SSL_CTX_set_keylog_callback` in the binary, luckily for me these were both external symbols of a dynamic framework.

With the above [Frida](https://frida.re/) snippet we can dump the TLS session keys the app generates, while running a TCP dump on `rvi0` to capture the encrypted traffic.

{% highlight bash %}
tcpdump -i rvi0 -w out.pcap -P
{% endhighlight %}

Then in a different terminal.

{% highlight bash %}
frida -U \
      -f {YOUR_BINARY} \
      --codeshare k0nserv/tls-keylogger \
      -l inject.js \
      -o out.keylog \
{% endhighlight %}

Where `inject.js` calls `startTLSKeylogger` from the code share.

After capturing some traffic we can verify that the keys work with `tshark` as follows.

{% highlight bash %}
grep -f \
  <(tshark -r out.pcap \
           -Y tls.handshake.type==1 \
           -T fields -e tls.handshake.random \
   ) out.keylog \
{% endhighlight %}

If they do simply open Wireshark with the captured dump and the keylog.

{% highlight bash %}
wireshark -r out.pcap -o tls:keylog_file:out.keylog
{% endhighlight %}

Voila, decrypted HTTPS traffic.
