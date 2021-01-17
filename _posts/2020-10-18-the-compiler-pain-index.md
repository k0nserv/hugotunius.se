---
layout: post
title: "The Compiler Pain Index"
date: 2020-10-18
categories: programming rust
description: >
  Why does anyone put up with the pedantic and strict Rust compiler?
---

One day when [doomscrolling](https://en.wikipedia.org/wiki/Doomscrolling) on Twitter, I saw this [tweet](https://twitter.com/mountain_ghosts/status/1301878824737611778) from [James Coglan](http://jcoglan.com/) and decided it would be a good topic for a long form writeup.

For completeness here's the full tweet:

> gonna keep thinking about how rust pulled off something that shouldn't work on paper: making devs "do more work" with more static modelling and a very hard-to-please compiler, and ended up with anyone going "this is actually great"

While I am sure James' tweet is at least partially sarcastic, it did get me thinking about why people do put up with Rust's compiler. This post is a long form version of [my thoughts in response](https://twitter.com/K0nserv/status/1301902296595431425) to James' tweet.

Let's talk about the concept of a "compiler". Throughout this post I'll use the term loosely and sometimes incorrectly to mean "interpreter" too. I will talk about a compiler accepting your program, which strictly speaking interpreters, like python, almost always do. However they might immediately crash with runtime errors. A python program that runs without syntax errors is considered "accepted", for compiled languages a programs is accepted if the compiler compiles it successfully.

So why does anyone put up with the Rust compiler? My short answer is: the level of input effort required to please the Rust compiler pays off in the output program. To make this clearer let's define "input effort" and "compiler output".

+ **Input effort** means the time and mental energy required to make the compiler accept your program.
+ **Compiler output** means the likelihood that the resulting program works correctly, is safe, and performant. The _"If it Compiles it Works"_-factor if you will.


With Rust specifically the **input effort** is quite high. The compiler is strict about a lot of things and will not accept programs that don't follow certain rules. For example, the Rust compiler has to be able to prove that references to values follow the rules of ownership; i.e. no immutable and mutable references to a value can exists at the same time. However, by enforcing these rules the **compiler output** can have certain guarantees. For example, programs accepted by the Rust compiler are _mostly_ free from race conditions because of these ownership rules. I put up with the Rust compiler because when my program is accepted by the compiler, I have high confidence that it will be correct. Said another way, Rust has a high _"If it Compiles it Works"_-factor.

## The Compiler Pain Index

With this concept of **input effort** and how it translates to **compiler output** we can plot different languages on a graph which gives us the compiler pain index. The index is the ratio of input effort to compiler output. None of this is particularly scientific, but it doesn't have to be to get the idea across.

<svg class="svg-illustration" viewBox="0 0 665 500" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-role="img" aria-label="The compiler pain index. The ratio between input effort and compiler output">
    <title>The compiler pain index</title>
    <desc>The ratio between compiler input effort and compiler output.</desc>
    <g id="compiler-pain-index-dark-mode" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <line x1="41" y1="459" x2="645" y2="20" class="line" stroke-opacity="0.92" stroke="#FFFFFF" stroke-width="2" stroke-linecap="square" stroke-dasharray="8,20"></line>
        <polyline id="Path-2" stroke="#999999" stroke-width="2" points="645 459 41 459 41 20"></polyline>
        <text id="Input-Effort" transform="translate(18.500000, 240.500000) rotate(270.000000) translate(-18.500000, -240.500000) " font-size="18" font-weight="normal" fill="#FFFFFF" fill-opacity="0.9">
            <tspan x="-23.5" y="247">Input Effort</tspan>
        </text>
        <text id="Compiler-Output" font-size="18" font-weight="normal" fill="#FFFFFF" fill-opacity="0.9">
            <tspan x="270" y="488">Compiler Output</tspan>
        </text>
        <g id="Rust" transform="translate(484.000000, 163.000000)" fill-opacity="0.92">
            <circle class="oval" fill="#11A8CA" cx="4" cy="10" r="4"></circle>
            <text font-size="16" font-weight="normal" fill="#FFFFFF">
                <tspan x="12" y="15">Rust</tspan>
            </text>
        </g>
        <g id="Java" transform="translate(343.000000, 173.000000)" fill-opacity="0.92">
            <circle class="oval" fill="#11A8CA" cx="4" cy="10" r="4"></circle>
            <text font-size="16" font-weight="normal" fill="#FFFFFF">
                <tspan x="12" y="15">Java</tspan>
            </text>
        </g>
        <g id="Python" transform="translate(132.000000, 383.000000)" fill-opacity="0.92">
            <circle class="oval" fill="#11A8CA" cx="4" cy="10" r="4"></circle>
            <text font-size="16" font-weight="normal" fill="#FFFFFF">
                <tspan x="12" y="15">Python</tspan>
            </text>
        </g>
    </g>
</svg>

A language like Python is different from Rust. The **input effort** required to please the compiler is very low, the code needs to be valid Python syntax, but in return we get very little in terms of **compiler output**. There are few guarantees about the resulting program and my confidence that it will work is much lower than with Rust. Python has a low _"If it Compiles it Works"_-factor and that's okay because with Python the level of **input effort** feels appropriate for the **compiler output**. A bad language would be one that required unjustifiably high **input effort** for the resulting **compiler output**. By comparison, a good language would be one where the **input effort** is low compared to the resulting **compiler output**.

Every programmer will have different ideas about which languages are "good" and "bad" using this metric. Personally, I feel like Java requires too much **input effort** to justify the **compiler output** it provides.

Of course, this is just a single metric to measure a programming language by and, as I've said, programming is about tradeoffs. Java might require too much **input effort** for the **compiler output**, but it has significant other upsides which often makes it a good choice.


<style type="text/css">
svg .oval {
  fill: var(--primary-color, #000);
}

svg text {
  fill: var(--text-color, #000);
}

svg .line {
  stroke: var(--text-color, #000);
}
</style>
