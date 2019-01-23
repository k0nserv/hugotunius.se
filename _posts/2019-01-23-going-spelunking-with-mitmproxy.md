---
layout: post
title:  "Going Spelunking with mitmproxy"
categories: security mitmproxy reverse-engineering
date: 2019-01-23
description: >
    Going spelunking with mitmproxy and finding things that scare you.
---

From time to time I like to fire up [mitmproxy](https://mitmproxy.org/) and route my phone's traffic through my computer. This allows your computer, via mitmproxy, to inspect and even alter HTTP(s) requests applications and other services on your phone are performing.

Most recently I have been looking a bit location data and marketing. I discovered that upon launching the Deliveroo app extremely precise location data is sent to a company called [Braze](https://www.braze.com/). Braze has other well known customers like GAP, Microsoft, KFC, Dominos, okcupid. Not all use of Braze will send this granular location data though.

> On app launch Deliveroo sends stupidly accurate location data(15 decimals, metre precision) to a market company called Braze(formerly AppBoy). Many other apps do similar things and it’s slightly terrifying.


![]({{ 'img/spelunking-with-mitmproxy/deliveroo-braze.jpg' | asset_url }})

[https://twitter.com/K0nserv/status/1087753850088554496](https://twitter.com/K0nserv/status/1087753850088554496)

## Knowledge is Power

Since knowledge is power I decided I should write up the method used here so you dear reader can also go spelunking.

There are many ways to install mitmproxy and they are all documented on the [mitmproxy documentation site](https://docs.mitmproxy.org/stable/overview-installation/). On macOS the easiest way is using the excellent tool [Homebrew](https://brew.sh/).

{% highlight bash line %}
brew install mitmproxy
{% endhighlight %}

After installing `mitmproxy` it is easy to start by just invoking it

{% highlight bash line %}
mitmproxy
{% endhighlight %}

mitmproxy acts as a HTTP(s) proxy and in order to tunnel your phone's traffic through your computer you need to set the computer as a proxy on your phone.

On iOS this is done under `Wi-Fi > Configure Proxy`. Here you want to configure a manual proxy pointing to the local ip of your computer, you can find out what your local ip is with `ifconfig` on macOS and Linux and `ipconfig` on Windows. For the port use `8080`.


![]({{ 'img/spelunking-with-mitmproxy/ios-proxy-config.jpeg' | asset_url }})

For Android consult this [Stack Overflow question](https://stackoverflow.com/questions/21068905/how-to-change-proxy-settings-in-android-especially-in-chrome)

At this point if you navigate to `http://example.com` on your phone the request should show up on your computer. However all HTTPS request will fail because mitmproxy is trying to man in the middle the request which will cause untrusted certificate errors. To remedy this navigate to `mitm.it` on your phone and click the icon for your OS. This will prompt you to install a root certificate for mitmproxy so it can decrypt HTTPS traffic.

**Note:** You should be careful about installing root certificates as doing so can defeat HTTPS completely if the certificate is from a malicious actor. The mitmproxy certificate is fine to install.

On iOS you additionally need to trust the certificate under `General > About > Certificate Trust Settings`. At this point HTTPS request should also start showing up on your computer.


## Going Spelunking

Now you are ready to go spelunking. Most apps will send certain interesting requests only on startup so killing an app and starting it again is advisable. In mitmproxy you can nagivate in the request flow with the `j` and `k` keys to. Selecting a specific flow with `enter` opens a detailed overview over the request. The detailed view shows request information as well as the response the server returned. You can switch between these with `tab`. `q` takes you back to the request flow. `z` clears the request flow which can be useful when it starts filling up.

**Pro Tip:** In any view in mitmproxy you can press `?` to show a list of available actions and which key(s) they are bound to.

The request flow can be filtered with `f` using a pretty advanced [query syntax](https://docs.mitmproxy.org/stable/concepts-filters/). For example when I was looking for apps that send my location data I used the following filter


{% highlight plain line %}
(~bq latitude | ~bq longitude | ~bq lat | ~bq long | ~bq lng)
{% endhighlight %}

If you find anything interesting feel free to [tweet at me](https://twitter.com/k0nserv).

Happy spelunking 😄
