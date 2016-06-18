---
title: The Death of Xcode Plugins
layout: post
categories: dev-environment apple
date: 2016-06-17
redirect_from:
  - /2016/05/17/the-death-of-xcode-plugins.html
description: >
  Xcode's Source Editor Extensions were
  announced at WWDC. Initially exicting the
  lacklustre platform proved disappointing.
---



It's WWDC week and as usual Apple has a lot of exciting announcements. This year
Apple announced [Source Editor Extensions](https://developer.apple.com/videos/play/wwdc2016/414/) for Xcode.
A new extensions system that allows developers to extend the functionality of Xcode. As a [plugin](https://github.com/k0nserv/luft)
developer myself I was [excited](https://twitter.com/K0nserv/status/742478939155800064) to see Apple finally
working on first party support for Xcode extension. However as I explored the new API my excitement
quickly faded and was replaced with disappointment.

Xcode plugins are built using completely undocumented APIs found by reverse-engineering Xcode
and inspecting the running instance. It's a brittle way to build plugins and it's fairly complicated.
I was initially glad to see Apple announce a better way to build extensions because it would make all
plugins more stable and simplify development. Immediately I was excited to port [Luft](https://github.com/k0nserv/luft).
As I later came to learn what Apple had announced is a completely lacklustre platform that is extremely
limiting in what kind of extensions can be built. On top of this they've also decided to stop loading
old plugins in Xcode 8 at all.

Ultimately most existing plugins will not be around anymore in Xcode 8.
They can't be implemented using Source Editor Extensions and they will not be loaded by Xcode 8. Luft is
one of them, another is a personal favourite of mine [XVim](https://github.com/XVimProject/XVim). Of the 275
plugins in the [Alcatraz](http://alcatraz.io/) plugin manager I suspect a large chunk of them will have the same
fait as Luft and XVim. It will probably take years for the platform to develop far enough to allow a new XVim,
if it ever will.

The good news are that Apple is recognizing the need to extend Xcode and working to provide a way to do this,
but their execution is lacking and shakes my confidence in this change going forward. On a personal note I am
slightly happy that I no longer work with Xcode in my day job.

Apple suggests plugin developers open radars for missing behavior in Source Editor Extensions. I've opened
the following that would be needed to implement Luft using Source Editor Extensions.

+ [Allow Source Editor Extensions to run on source change](https://openradar.appspot.com/radar?id=4933149876289536)
+ [Support Source Editor Extensions Preferences](https://openradar.appspot.com/radar?id=5001777682317312)
+ [Allow updating the Xcode gutter via Source Editor Extensions](https://openradar.appspot.com/radar?id=4985435868626944)
