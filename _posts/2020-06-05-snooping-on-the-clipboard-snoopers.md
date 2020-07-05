---
layout: post
title: "Snooping on the Clipboard Snoopers"
categories: security mitmproxy reverse-engineering frida ios privacy
date: 2020-06-05
description: >
  With iOS 14 Apple exposed the apps that snoop on user's clipboard but what's the purpose of said snooping?

---

It has become a somewhat of a tradition for Apple to announce new measures to safe guard user privacy at [WWDC](https://en.wikipedia.org/wiki/Apple_Worldwide_Developers_Conference), their annual developer conference. Despite a different format, due to the COVID crisis, this proved to be that case for [WWDC2020](https://developer.apple.com/wwdc20/) as well. Apple announced restrictions on access to sensitive data, a new framework for tracking consent, and a notification when apps read from the iOS/iPadOS clipboard.

As is typical Apple immediately dropped beta versions of their software after the main keynote. As people started to use the beta versions of iOS and iPadOS the new notification when apps access the clipboard, sometimes referred to as the pasteboard, took centre stage. Lots of apps that seemingly have no good reason to be reading the contents of the clipboard were doing just that.

[![Screenshot of The Wall Street Journal app reading the clipboard from 1Password]({{ 'img/snooping-on-the-clipboard-snoopers/WSJ-clipboard.png' | asset_url }})](/img/snooping-on-the-clipboard-snoopers/WSJ-clipboard.png)

These notifications rightly put a lot of users on edge. Consider the above screenshot of The Wall Street Journal's app reading data from my clipboard which contained a password I had just copied from my password manager, 1Password. This would makes most people uneasy.

The jump to conclusions that apps were reading the clipboard contents for nefarious and user hostile reasons came immediately. At the centre of this was [TikTok](https://www.tiktok.com/), the massively popular social video network made by the Chinese company [ByteDance](https://bytedance.com/). But how much truth is there to these accusations of malicious intent and gross privacy violations? Let's find out.

## Snooping

I have a keen interest in information security and having spent a big part of my career as an iOS developer I am especially interested in iOS apps. So I decided to investigate some of the apps accused of snooping on the clipboard. I reviewed most of the apps [discovered to be snooping](https://www.mysk.blog/2020/03/10/popular-iphone-and-ipad-apps-snooping-on-the-pasteboard/) by [Tala Haj Bakry](https://www.linkedin.com/in/hajbakri/) and [Tommy Mysk](https://twitter.com/tommymysk). Some of the apps they discovered to be snooping on clipboard has since removed the offending code but many continue to snoop. Interestingly Tala and Tommy performed their research much earlier than WWDC but the practice garnered increased attention after iOS 14 and the clipboard notifications.


### Methodology

Broadly I wanted to understand two things:

1. If and when an app snooped on the clipboard
2. If the data from the clipboard was exfiltrated off the device

My test device is an iPhone 6s running iOS 13.1.2 with the [CheckRa1n](https://checkra.in/) jailbreak. While I didn't run these tests on an iOS 14 the APIs that cause the notifications on iOS 14 are available and can be monitored on iOS 13. To monitor access to the clipboard I used [Frida](https://frida.re/), a dynamic instrumentation toolkit, to look for method calls on the  [`UIPasteboard`](https://developer.apple.com/documentation/uikit/uipasteboard) class.

Specifically I consider an app to be snooping on the clipboard when it calls `+ [UIPasteboard generalPasteboard]` followed by later calling `- [UIPasteboard string]` or `- [_UIConcretePasteboard string]`. I used `frida-trace` to watch these calls and others `frida-trace -U -m "*[UIPasteboard *]" -f {app_identfier}`.

My attempt to find apps that exfiltrated the contents of the clipboard revolved around copying a highly unique string(the SHA256 of the string **Black Lives Matter**) and proxying the device's traffic through mitmproxy. In mitmproxy I used the filter

{% highlight plain %}
(
  ~b bb11f8b8e9a85e64109b116ca99223bd682dd3e066c8ed1e0069da6f6233e485 |
  ~h bb11f8b8e9a85e64109b116ca99223bd682dd3e066c8ed1e0069da6f6233e485 |
  ~u bb11f8b8e9a85e64109b116ca99223bd682dd3e066c8ed1e0069da6f6233e485
)
{% endhighlight %}

to identify any outgoing request that contained the contents of the clipboard. I also did some tests with parts of this string encoded as base64.

When I identified clipboard access I further reviewed this access with [Hopper](https://www.hopperapp.com/) to understand what the app was doing with the data and the purpose of the access.

It should be noted that a truly malicious app would detect that the device is jailbroken or that it's otherwise being observed and stop any malicious activity. I did not attempt to circumvent any such detection.


### Findings

I reviewed 43 apps out of which about 23 snooped on the clipboard in a way that I deemed concerning(on app launch and whenever the app entered the foreground). I found no instances of an app exfiltrating the contents of the clipboard to remote servers but my method for identifying this is naive.

For the apps that snooped on the clipboard on launch and when entering the foreground I found that this was mostly features of third party SDKs these apps had embedded.

9 of the apps I found were using [Firebase Dynamic Links](https://firebase.google.com/docs/dynamic-links/) which reads the clipboard every time the app enters the foreground to look for a copied dynamic link. Since Firebase Dynamic Links is open source we can [see exactly what it does](https://github.com/firebase/firebase-ios-sdk/blob/2440f5603969a3006fbd6bfb1be4d99771e3fb3f/FirebaseDynamicLinks/Sources/FIRDLDefaultRetrievalProcessV2.m#L271-L314). There's also an [issue](https://github.com/firebase/firebase-ios-sdk/issues/5893) about this behaviour.

18 of the apps were accessing the clipboard due to code from [Google's Mobile Ad SDK](https://developers.google.com/admob/ios/download). While there were a few different versions of this code they all seemed to relate to a feature in the SDK to support reading some sort of configuration from the clipboard, presumably a feature to aid development.

The last case was AliExpress which has custom code that seems very similar to that of the above described SDKs. It reads the clipboard on launch from the method `+ [AEAECodeDetectCommand execute]` which looks to be looking for some sort of configuration in the clipboard.

The Wall Street Journal's app which I highlighted at the start of the post uses both Firebase Dynamic Links and Google's Ad SDK.


## Conclusion

While the new notifications introduced with iOS 14 highlights clearly how many apps access the device clipboard I have not found anything in the apps I analysed that pointed to anything malicious. However these new notifications are a good tool that give users all the information to call out unreasonable clipboard access and I applaud Apple for adding them. In a future version of iOS Apple will hopefully require explicit permission before accessing the clipboard.

Of course there's nothing stopping an app from doing far more nefarious things with the clipboard data than I have identified here and with encryption and other obfuscation techniques it is difficult to spot such behaviour without deep analysis.

If you have any apps you'd like me to look at please DM me on [Twitter](https://twitter.com/k0nserv).


To end with I'd like to highlight the excellently named framework The Wall Street Journal includes to wrap Ad SDKs, `ChanceTheAdWrapper`.

[![A screenshot of a stacktrace showing the Wall Street Journal's Ad library wrapper ChanceTheAdWrapper]({{ 'img/snooping-on-the-clipboard-snoopers/chance-the-ad-wrapper.png' | asset_url }})](/img/snooping-on-the-clipboard-snoopers/chance-the-ad-wrapper.png)
