---
layout: post
title: "The Sword Juggling Fallacy"
categories: opinion rust c
description: >
    Sword juggling is simple, just don't cut your fingers off in the process
---

Sword juggling is simple. I'll prove it to you by explaining it. First, acquire three -- or, if you feel ambitious, four swords. Divide the swords between your hands. Starting with one hand, the one holding two swords if juggling with three, toss a sword into the air. As this sword is about to reach your other hand, toss the sword in that hand and catch the falling sword by, and this is important, its handle, not the blade. Then repeat this process as the airborne sword reaches the hand you started with. Now keep doing this, ensuring that you do not cut your fingers off in the process. 

To make the subtext, well, text. This is an allegory about the C programming language, although it applies to others too. C being simple is a common idea, especially made in discussion about and as contrast to Rust. It's true that C is simple. The language is small and the standard is, relatively, short. Just like sword juggling is simple, C being simple doesn't mean programming in C is easy. In fact it's very hard, especially if you care about your program being correct. Simple is not easy. 

After learning the simple C language, a world of painful experiences await the aspiring C programmer. With each a new lesson is, hopefully, learned. This is not an indictment of individual programmers, as much as some people like to cry "skill issue", writing correct C is just hard. The canonical example is pointers: simple in theory, devilishly complex in practice. For every pointer you must consider: Who owns the memory it points to? Does it need to be freed? If so, who is responsible for freeing it? How big is the memory region it points to? Is it alive currently? Did someone already free it?

Obviously no one wants a language that's complex, at least not more complex than the inherent complexity of the domain. Returning to the pointer example above, anytime I have to write C and deal with pointers I'm filled with dread because I know I have to consider all of these questions carefully and getting it wrong has dire consequences. By comparison Rust's complex reference semantics, lifetimes, and borrow checker are a breeze; I know that outside of `unsafe` I'm not going to mess it up.

Sword juggling is simple, but not easy and I'd be remiss if I didn't mention that [unsafe Rust is a bit like juggling with chainsaws](https://oxide.computer/blog/iddqd-unsafe).
