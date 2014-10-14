---
layout: post
title:  "Open Source, draft title"
categories: open-source
---

On July the 7:Th I went to the CocoaHeads Stockholm meetup as I always try to do when they host one. For this particular meetup the brilliant, but unknown to me at the time, [Orta Therox](https://twitter.com/orta) held a talk about open source, [CocoaPods](http://cocoapods.org/) and how they work at [Artsy](https://artsy.net/). For very long time beforehand I had felt that I was not contributing back enough to all the awesome projects that I used daily, CocoaPods being one of them. Orta really inspired me to take the first steps to contribute back. This post is about my experience starting out and the problems I overcame in the process. The idea for this post orginated in a discussion about the mentailty of open source amoung many programmers.

## The question

In the mentioned the discussion the original questions was:

> Why do Github issues often become filled people saying things like **+1**, 
**I need this** and **Would be awesome** instead of PRs solving the issue?

## My Answer

From my very personal, but probably non-unique experience, it's really a mentality issue more than anything. Ultimately it's related to my confidence as a programmer and a slight touch of [Impostor Syndrome](https://en.wikipedia.org/wiki/Impostor_syndrome).

### I can't provide value

A statement that I often used to justify my passivity was **I can't provide value here, the other contributors are just too skilled**. It's true that many open source projects are huge behemoths with a lot of code and things to understand, but every single contribution still matters and provides immense value to the project. A project without contributions, big or small, will stagnate. 

I think there's also an important point to be made here about making the project accessible for new contributors. It should be as simple as possible to get started, that means setup of environment and finding issue which are suited for contributors who are not yet familiar with the codebase. CocoaPods does both of these very well. 

For setup there's  a repository called [Rainforest](https://github.com/CocoaPods/Rainforest) which contains a rake task to setup everything needed to develop Cocoapods. Additionally almost all repositories contain a rake task called `bootstrap` which will setup the repository for development. 

For finding issues CocoaPods uses a labeling systems to illustrate how difficult an issue is as seen [here](https://github.com/CocoaPods/CocoaPods/labels). The label `easy` is perfect for fiding tasks for new contributors. In fact I have started working on quite a few of them, but many times I ran into problems which were difficult or things I simply didn't understand about the way it worked. I abandoned quite a few issues because of getting stuck, which is both good and bad. It's good because it's important that you are able to try your hand at solving issues and failing without being assigned the issue or feeling pressure to finish it. The bad part leads me to the next issue I had, asking questions.

### I shouldn't waste the core contributors time by asking trivial questions

Even after getting passed the initial feeling of not being able to provide any value, landing my first PR helped with this, I was still reluctant to ask the core contributors questions because I felt like I was wasting there time. To quote myself from the discussion we had.

> That's one of my concerns. I know that everyone else can implement trivial things much faster than me. I try to weigh asking question against that to not produce negative value

While it's true that having core contributors spending time on helping you might produce negative net value in the short term, in the long term you will end up with more developers who are productive and familar with the codebase. 

To be continued...

