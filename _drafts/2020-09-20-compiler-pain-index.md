---
layout: post
title: "The Compiler Pain Index"
categories: programming rust
description: >
---

<style type="text/css">
svg .oval {
  fill: var(--highlight-color, #000);
}

svg text {
  fill: var(--text-color, #000);
}

svg .line {
  stroke: var(--text-color, #000);
}
</style>

Like many of my blog posts, this one starts with a [tweet](https://twitter.com/mountain_ghosts/status/1301878824737611778):

> gonna keep thinking about how rust pulled off something that shouldn't work on paper: making devs "do more work" with more static modelling and a very hard-to-please compiler, and ended up with anyone going "this is actually great"

In this tweet [James Coglan](http://jcoglan.com/) muses on how anyone puts up with Rust's strict and pedantic compiler. While I am sure James' tweet is at least partially sarcastic, it did get me thinking about why people do put up with Rust's compiler. This post is a long form version of [my thoughts in response](https://twitter.com/K0nserv/status/1301902296595431425) to James' tweet.

Anyone who has been programming for a significant amount of time has learned that things are rarely as black and white as a dogmatic statement like "PHP is a bad language" would imply. Programming is about tradeoffs. Even the apparent faults in some technologies weren't obvious at the time they were introduced and have helped inform and shape technologies that came later. For example: ["The Billion Dollar Mistake"](https://en.wikipedia.org/wiki/Null_pointer) lead to the invention of better solutions to this problem. Still, programmers are human and humans are prone to dogma. A single bad experience might be enough to incite intense dislike of some technology. This blog post will reflect some of my own dogma and opinion, but the general idea applies to everyone simply substitute your own opinion.

In this blog post I'll talk about the concept of a "compiler", but I'll use the term loosely and sometimes incorrectly to mean interpreter too. I will talk about a compiler accepting your program which strictly speaking interpreters like python almost always do even though they might immediately crash with runtime errors. A python program that runs without syntax errors is considered "accepted", for compiled languages a programs is accepted if the compiler compiles it successfully albeit with warnings.

Back to James' question, why does anyone put up with the Rust compiler? My short answer to this question is: the level of input effort required to please the Rust compiler pays off in the output program. To make this clearer let's define "input effort" and "compiler output" strictly.

+ **Input effort** means the time and mental energy required to make the compiler accept your program.
+ **Compiler output** means the likelihood that the resulting program works correctly, is safe and performant. This can be summarize as the _"If it Compiles it Works"_-factor.

With Rust specifically the **input effort** is quite high. The compiler is strict about a lot of things and will not accept programs that don't follow certain rules. For example the Rust compiler has to be able to prove that references to values follow the rules of ownership i.e. no immutable and mutable references to a value can exists at the same time. However by enforcing these rules the **compiler output** can have certain guarantees. For example programs accepted by the Rust compiler are _mostly_ free from race conditions because of the ownership rules enforced by the compiler. I put up with the Rust compiler because when my program is accepted by the compiler I have high confidence that it will be correct. The Rust compiler is also excellent at guiding you when it isn't satisfied with your program via it's superb error messages.

## The Compiler Pain Index

With this notion of **input effort** and how it translates to **compiler output** we can plot different languages on a graph.

<svg class="svg-illustration" viewBox="0 0 665 500" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <title>compiler-pain-index-dark-mode</title>
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

A language like Python is different from Rust. The **input effort** required to please the compiler is very low, the code needs to be valid Python syntax, but in return we get very little in terms of **compiler output**, there are few guarantees about the resulting program and my confidence that it will work is much lower than with Rust. With Python the level of **input effort** feels appropriate for the **compiler output** you get in return. A bad language would be one that required unjustifiably high **input effort** for the resulting **compiler output**. By comparison a good language would be one where the **input effort** is low compared to the resulting **compiler output**.

I believe every programmer will have different ideas about which languages are "good" and "bad" using this metric. Personally I feel like Java requires too much **input effort** to justify the **compiler output** it provides.

Of course this is just a single metric to measure a programming language by and as I said at the top programming is about tradeoffs. Java might require too much **input effort** for the **compiler output**, but it has significant other upsides which often makes it a good choice anyway.


