---
layout: post
title:  "The Apps That Are Listening to You"
categories: privacy ios
date: 2021-01-10
description: >
  Are there apps that listen to your microphone or otherwise use audio data for third party tracking? If so which are they?
---



An oft discussed hypothesis is that certain apps, usually Facebook, listens to and analyses your surroundings for ad targeting purposes. It has never been conclusively proven that Facebook does this, but there are plenty of people on the internet with anecdotal stories of ads appearing for products they've only discussed IRL. In iOS 14 Apple added indicators to highlight when an app is using the device's microphone or camera. Since I have access to a decently sized collection of app privacy details I decided to have a look if any apps admit to this behaviour.

This is an extension of my previous work on [analysing privacy on the app store](https://hugotunius.se/2021/01/03/an-analysis-of-privacy-on-the-app-store.html), I'd recommend reading that post before this one.

In this post I am looking at apps that collect *"Audio Data"* under the *"User Content"* category for third party tracking use i.e. `DATA_USED_TO_TRACK_YOU`. Apple defines audio data as *The user’s voice or sound recordings*, thus it's not definite if these apps listen to your microphone or use some other type of sound recording.

My data set contains 18 835 apps, but only slightly more than a third of those have provided privacy details. Of these apps there are seven that confess to collecting audio data for third party tracking purposes:

+ [Chime - Mobile Banking](https://apps.apple.com/us/app/chime-mobile-banking/id836215269)
+ [Periscope Live Video Streaming](https://apps.apple.com/gb/app/periscope-live-video-streaming/id972909677)
+ [Football Index - Bet & Trade](https://apps.apple.com/gb/app/football-index-bet-trade/id1068187100)
+ [Magic Piano by Smule](https://apps.apple.com/us/app/magic-piano-by-smule/id421254504)
+ [Paxful Bitcoin Wallet](https://apps.apple.com/us/app/paxful-bitcoin-wallet/id1443813253)
+ [Min Doktor – läkare i mobilen](https://apps.apple.com/kw/app/min-doktor-l%C3%A4kare-i-mobilen/id1104213750)
+ [Monifi - Mobile Banking](https://apps.apple.com/us/app/monifi-mobile-banking/id1525138651)


## Update History

| **Date**   | **Changes**                  |
|------------|------------------------------|
| 2020-01-10 | Initial publication          |
| 2020-01-17 | Updated with larger data set |
