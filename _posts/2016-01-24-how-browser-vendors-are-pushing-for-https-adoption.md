---
layout: post
categories: web security ux
title: How browser vendors are pushing for HTTPS adoption
---

It's 2016 and many sites have still not deployed HTTPS fully even though it's now [free][lets_encrypt] and largely available. Prominent websites that deal with sensitive user data are doing so in completely broken [ways](http://www.troyhunt.com/2013/05/your-login-form-posts-to-https-but-you.html). Luckily the browser vendors and the web community is working to make users aware of such practice and even lockdown access to certain APIs on insecure origins.

## Secure origin

It's important to think about what is and what is not a secure origin. A fairly common practice is to load iframes from a secure origin in an insecure page.

{% highlight html line %}
<!-- on http://example.com -->
<body>
  <iframe src="https://secure.example.com/"></iframe>
</body>
{% endhighlight %}

This is of course not secure, because an attacker can completely replace the `iframe` before the page reaches the user. In the same fashion loading some DOM over ajax from `https://secure.example.com` on the page `http://example.com` is not secure. There are many more ways to mess up secure origins and in the end the only good solution is making everything HTTPS. This work in progress [draft](https://w3c.github.io/webappsec-secure-contexts/) from W3C describes fully what constitutes a secure context.

## The browser vendors

So what are the browser vendors doing to push for the adoption of HTTPS? They are sponsoring initiatives such as [Let's Encrypt][lets_encrypt], they are starting to restrict access to certain features from insecure origins, they are highlighting to the user when their data might be at risk due to poorly implemented HTTPS.

In the current Firefox nightly build insecure pages with an input with `type="password"` are being marked explicitly as insecure and the user is informed that their login data might be compromised if they proceed. As seen here on twitch.tv Firefox clearly indicates that logging in to Twitch could compromise your password.

[![]({{ 'img/https-browser/twitch-in-firefox.png' | asset_url }})](/img/https-browser/twitch-in-firefox.png)

This is one of my favourite moves to increase HTTPS adoption because it is of great benefit to the user and it's clear to the user that their security is at risk. In many companies investing in HTTPS might not be considered important until users start complaining. Hopefully with this change such complaints will increase.


The chromium project is [planning to remove "Powerful Features" on insecure origins](https://www.chromium.org/Home/chromium-security/deprecating-powerful-features-on-insecure-origins). The features currently listed to be removed are.

+ Device Motion / orientation
+ EME (Encrypted Media Extensions)
+ Fullscreen
+ Geolocation
+ getUserMedia (audio and video support)

Some of these features give developers access to sensitive data such as location, video and audio. As such only allowing them on secure origin is a good move forward and will greatly benefit users. At the time of writing these features are deprecated, but not removed on insecure origins in Chrome. Firefox has stated that they are looking into doing the same.

According to [Motherboard](https://motherboard.vice.com/read/google-will-soon-shame-all-websites-that-are-unencrypted-chrome-https) Chrome will also soon start explicitly marking HTTP as insecure. Users can already opt in for this behaviour, which will show a padlock with a red "x" on HTTP pages, by going to `chrome://flags/#mark-non-secure-as` and changing the value from `default`. Here's a screenshot of what this looks like.

[![]({{ 'img/https-browser/http-insecure-chrome.png' | asset_url }})](/img/https-browser/http-insecure-chrome.png)

## The user

It's important to remember that the actions that the browser vendors are taking are not specifically to encourage developers to adopt HTTPS. At the end of the day they are concerned with the user's security as every developer should be as well. Unfortunately security does not always get the focus and attention it demands and in modern business it's sadly not always viewed as important. Fortunately these changes from the browser vendors will shift the focus and increase developers and business awareness.


[lets_encrypt]: https://letsencrypt.org/
