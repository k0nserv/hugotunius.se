---
layout: post
title: "On Async Rust"
categories: programming rust opinion
date: 2024-03-08
description: >
    Reflections on my experience with async rust and the recent slew of criticism of it.
---

I started using Rust in 2017, before the stabilisation of async/await. When it was stabilised I managed to avoid it for a few more years before it was time to grapple with it. It’s fair to say that async Rust is one of the hairiest parts of the language, not because the async model is poorly designed, but because of the inherent complexity of it in combination with Rust’s goals. There have been many blog post written about async and its perceived shortcomings, as well as excellent explainers and history lessons, mostly from [`withoutboats`](https://without.boats/).

In this post I want to reflect on my experience and journey with async and my thoughts on some of the criticisms levied against async. Starting with: do we really need `N:M` threading anyway?

## Do we Really Need N:M threading?

A favourite maxim of mine is: “Computers are fast actually”. My point being that, as an industry, we have lost touch of quite how much modern computers are capable of. Thus, I’m naturally favourable to the idea that N:M threading is oftentimes overkill and most applications would be well-served by just using OS threads and blocking syscalls. After all the C10k(and more) problem is trivially solvable with just OS threads. Many applications could avoid the complexity of async Rust and still be plenty performant with regular threads. 

However, it doesn’t really matter what I think, or even if it’s true that most applications don’t need N:M threading, because developers, for better or worse, **want** N:M threading . Therefore, for Rust to be competitive with Go, C++, et al. it must offer it. Rust has a very unique set of constraints that makes solving this problem challenging, one of which is zero-cost abstractions. 

## Zero-Cost Abstractions 

Rust’s goal of providing zero-cost abstractions, i.e. abstractions that are no worse than writing the optimal lower level code yourself, often comes up in discussions around async Rust and is sometimes misunderstood. For example, the idea that async Rust is a big ecosystem with many crates and building all of those crates as part of your application is a violation of the zero-cost abstractions principle. It isn’t, zero-cost is about runtime performance. 

The zero-cost goal helps guide us when discussing alternative async models. For example, Go is lauded for its lack of function-colouring and its sometimes suggested Rust should copy its approach. This is a no-go(😅) because Go’s approach is decidedly **not** zero-cost and requires a heavy runtime. Rust did actually feature green threads, which are similar to coroutines, in an earlier version of the language, but these were [removed](https://github.com/rust-lang/rfcs/blob/master/text/0230-remove-runtime.md) precisely because of the runtime requirement.

## The `Arc<Mutex>` in the room

Another common point of contention is the tendency for async Rust to require a lot, and I do mean **a lot**, of types like `Arc` and `Mutex`, often in combination. I experienced this myself when starting out with async Rust, it’s easy to solve local state synchronisation problems with these constructs without properly thinking about the wider design of your application. The result is a mess that soon comes back to bite you. However, discussing this in the context of async Rust and as an “async problem” is unfair, it’s really a concurrency problem and it will manifest in applications that achieve concurrency with OS threads too. Fundamentally, if you want to have shared state, whether between tasks or threads, you have to contend with the synchronisation  problem. One of my big lessons in learning async Rust is to not blindly follow compilers errors to “solve” shared state, instead take a step back and properly considered if the state should be shared at all. 

This problem is similar to the notorious borrow checker problems Rust is infamous for. When I started learning Rust I often ran into borrow checker problems because I wasn't thinking thoroughly about ownership, only about my desire to borrow data. `Arc<Mutex>` and friends sometimes betray a similar lack of consideration for ownership.

## Critiquing Async Rust

All of the above form the context to be considered when critiquing async rust. Simply stating that Rust should abandon zero-cost abstractions is easy, while providing constructive feedback that takes this goal into consideration is not. The same is true about the suggestion that Rust should not have an async programming model at all. Within these bounds, constructive criticism of Rust's async model is great, only by examining what's not working well can lessons be learned for the future and the language improved. All this said, there are definitely problems with async Rust. 

When you go looking for crates to perform anything remotely related to IO e.g. making HTTP requests, interfacing with databases, implementing web servers, you'll find that there is an abundance of async crates, but rarely any that are sync. Even when sync crates exist they are often implemented in terms of the async version, meaning you'll have to pull in a large number of transitive dependencies from the async ecosystem into your ostensibly sync program. This is an extension of the function colouring problem, it's **crate colouring**. The choice of IO model pollutes both a crate's API and it's dependency hierarchy. In the rare instances when only a sync crate exists the opposite problem occurs for sync programs, yes there's `block_on` and friends, but this is band-aid at best.

Even within the async ecosystem there's a problem, the dominance of Tokio. Tokio is a great piece of software and has become the de facto default executor. However, "default" implies the possibility of choosing a different executor, which in reality is not possible. The third party crate ecosystem isn't just dominated by async crates, but by crates that only work with Tokio. Use a different executor? Tough luck. You'll need to switch to Tokio or redundantly implement the crates you need for yourself. Not only do we have a crate colouring problem, but there are also more than [3 colours](https://without.boats/blog/let-futures-be-futures/#the-function-non-coloring-problem) because `async-tokio` and `async-async-std` are distinct colours.

[Async traits are slowly being stabilised](https://blog.rust-lang.org/2023/12/21/async-fn-rpit-in-traits.html), but this is just one place where the language and standard library lacks proper support for async. Drop still cannot be async and neither can closures. Async is a second-class citizen within Rust because the tools that are usually available to us, are off limits in async. There is interesting work happening to address this, namely [extensions to Rust's effect system](https://www.youtube.com/watch?v=MTnIexTt9Dk).

## Inverting Expectations

<style type="text/css">
:root {
    --light-blue-color: rgba(38, 140, 234, 1);
    --light-green-color: rgba(38, 234, 46, 1);
    --light-red-color: rgba(234, 38, 73, 1);
    --light-orange-color: rgba(234, 120, 38, 1);

    --dark-blue-color: rgba(115, 188, 255, 1);
    --dark-green-color: rgba(115, 255, 120, 1);
    --dark-red-color: rgba(255, 115, 140, 1);
    --dark-orange-color: rgba(255, 174, 115, 1);

    --blue-color: var(--light-blue-color);
    --green-color: var(--light-green-color);
    --red-color: var(--light-red-color);
    --orange-color: var(--light-orange-color);
}

@media (prefers-color-scheme: dark) {
    :root {
        --blue-color: var(--dark-blue-color);
        --green-color: var(--dark-green-color);
        --red-color: var(--dark-red-color);
        --orange-color: var(--dark-orange-color);
    }
    
    span.c {
        color: var(--background-color);
    }
}

span.c {
    padding: 0.1em 0.2em;
    border-radius: 2px;
}

span.b {
    background-color: var(--blue-color);
}

span.g {
    background-color: var(--green-color);
}

span.r {
    background-color: var(--red-color);
}

span.o {
    background-color: var(--orange-color);
}
</style>

The problems of function and crate colouring are intimately tied to how code is structured. When IO is internal to a piece of code, abstracting over its asyncness, or lack thereof, becomes complicated due to colouring. The colouring is infectious, if some code abstracts over the colours red and green, then that code needs to become a chameleon, changing its colour based on the internal colour of the IO. At the moment this chameleon behaviour is not achievable in Rust, although the effects extensions would allow it. Abstracting over the asyncness of IO is complicated, what if we instead were to avoid it with inversion of control.

The [sans-IO pattern](https://sans-io.readthedocs.io/) sidesteps the colouring problem by moving the IO out. Instead of abstracting over IO we implement the core logic and expect the caller to handle IO. Concretely this means that a set of crates implementing a HTTP client would be split into a `http-client-proto` crate and several user facing crates `http-client-sync`, `http-client-tokio`, `http-client-async-std`. Borrowing from `withoutboat`'s colour definitions, `http-client-proto` would be a <span class="c b">blue crate</span>, it does no IO and never blocks the calling thread, it implements the protocol level HTTP concerns such as request parsing, response generation etc. `http-client-sync` would be a <span class="c g">green crate</span> and `http-client-tokio` would be a <span class="c r">red crate</span>. As I hinted to before, a different async executor, at least in the absence of the aforementioned abstractions, is a different colour too so `http-client-async-std` would be an <span class="c o">orange crate</span>. This pattern has several benefits, it enables code sharing between differing IO models without bloating dependency trees or relying on the likes of `block_on`. A user that finds the crates `foo-proto` and `foo-tokio` can leverage `foo-proto` to contribute `foo-sync`, requiring less duplication. If every crate that deals with IO followed this pattern the problem of crate colouring would be greatly alleviated and significant portions of code could be shared between sync and async implementations.
