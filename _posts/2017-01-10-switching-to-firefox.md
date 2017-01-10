---
layout: post
title: "Switching to Firefox"
categories: web firefox chrome
date: 2017-01-10
description: >
  I've been a long time user of Chrome, but recently I've been concerned about the Chrome mono culture which is why I am switching back to Firefox as my default browser.

---



A long time ago ~~in a galaxy far far away~~ I used Firefox as my default web browser. I was running Windows XP and had just started learning PHP and C++. I kept using Firefox for a few years, but then during university I got tired of how slow Firefox was and jumped ship to Chrome.



At the time Chrome was new and shiny, it was lean and fast. Using Chrome was a refreshing experience and it provided a better developer experience with its built in developers tools(at the time Firebug had to be used in Firefox). For years since I've used Chrome as my default browser. I've seen it gain more and more adoption among developers and especially web developers. Chrome has managed to stay lean and fast, albeit using enormous amounts of RAM in the process. However recently tendencies I saw in myself and the community has been a point of concern. It feels like we are about to make the same mistake that was made with IE6 all over again with Chrome. Developers are developing in Chrome and often end up building for Chrome with other browsers as an afterthought. I have been guilty of this myself. So to start 2017 off I decided to switch back to Firefox again. 



Fortunately Mozilla has not been sitting idle while Chrome ate their market share. They've been working on some great projects to make Firefox faster and better. Notably they're bringing multi-process support to Firefox with [Electrolysis](https://wiki.mozilla.org/Electrolysis). When I switched to Chrome back in the day one of the strong reasons was the multi process architecture of Chrome. This not only means better performance it also isolates tabs from each-other which reduces the effect a single hanging tab has on the browser as a whole. I was happy to find that Electrolysis is a massive improvement for Firefox too. Initially after switching I didn't have Electrolysis turned on due to concerns about extension compatibility. However I quickly found myself annoyed at how sluggish and laggy Firefox could still be. I turned on Electrolysis and immediately experienced the sluggishness and lag disappear. Firefox felt on point with Chrome again. Mozilla has also been hard at work creating a new programming language, [Rust](https://www.rust-lang.org/en-US/). Getting my feet wet with Rust is something I want to do during 2017. They're using Rust to implement a new layout engine called [Servo](https://servo.org/) that promises improved parallelism, security, and performance. Servo is already beating the current layout engine Gecko in some benchmarks.

As I mentioned the usage of browser extensions along with Electrolysis was a concern intially, but I've found that for my favourite Chrome extensions there are good ports or similar extensions that work with Electrolysis. The extensions I've come to rely on in Chrome are [uBlock Origin](https://www.ublock.org/), [HTTPS Everywhere](https://www.eff.org/https-everywhere), [Vimium](https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb), [1Password](https://agilebits.com/onepassword/extensions), [Reddit Enhancement Suite](http://redditenhancementsuite.com/). All of these except Vimium exist as Firefox extensions and work well with Electrolysis enabled. To satisfy my vim addiction there's [VimFx](https://addons.mozilla.org/en-US/firefox/addon/vimfx/) which is inspired by Vimium. 



So far I'm very happy with this switch and I can honestly say that with Electrolysis Firefox has caught up with Chrome in terms of speed. I'm excited for what the future with Servo will look like. It feels good that I've stopped contributing to the Chrome mono culture and I'm also sending less data to Google which can only be a positive. I'd encourage other web developers to experiment with changing their default web browser away from Chrome too. 



