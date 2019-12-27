---
layout: post
title: "5 Awesome Rust projects"
categories: rust
date: 2017-10-22
description: >
  Rust has been around for 7 years now and a lot of cool software is being creeated with the langauge. This is an overview of 5 awesome project written in Rust.
---

A pet project by Mozilla employee [Graydon Hoare](https://twitter.com/graydon_pub) that grew to be one of Mozilla's most important endeavours, The [rust](https://www.rust-lang.org/en-US/) language was first announced in 2010. It was voted "most loved programming language" in the Stack Overflow developer survey in both 2016 and 2017.

There's a lot of interesting work being done with Rust and here are five of the  most interesting projects.

## Servo

[Servo](https://servo.org/) is Mozilla's headline project. A brand new browser engine written in Rust. Servo is exciting because it promise to bring a new better take on parallelism to the browser engine paradigm. Rust's excellent support and safety for parallel execution enables Servo to utilize the many cores of modern computers better than ever before. The best thing is we don't have to wait for Servo to be completed before these benefits are realized. With the [Quantum project](https://wiki.mozilla.org/Quantum) Mozilla aims to bring parts of Servo to Firefox before Servo is completed. The first step in this plan is [Stylo](https://wiki.mozilla.org/Quantum/Stylo), the CSS subsystem from Servo, landing in Firefox. It's enabled by default in Firefox 57 which is the current beta version. Those interested in this work should read [Inside a super fast CSS engine: Quantum CSS (aka Stylo)](https://hacks.mozilla.org/2017/08/inside-a-super-fast-css-engine-quantum-css-aka-stylo/) by [Lin Clark](https://twitter.com/linclark). I believe that Firefox is about to enjoy a renaissance as the best browser thanks to the improvements from the Servo project.


## Redox

![]({{ 'img/awesome-rust-projects/redox-ui.png' | asset_url }})

[Redox](https://www.redox-os.org/) is an ambitious project to build full Unix-like operating system with Rust. Using the Rust features it should achieve both high performance and memory safety which is absolutely crucial in an operating system. Building an operating system is an enormous challenge, but Redox has made impressive progress in the two years it's been in development.

## Cargo

[Cargo](https://crates.io/) is the Rust package manager. Like the language itself Cargo takes inspiration from the history of package managers that came before it. Cargo is a staple in the Rust ecosystem and is one of the things that makes working with Rust a joy. Like Rust it's both safe and fast. It features support for semver ranges in a manifest file(`Cargo.toml`). Like other excellent package managers, such as [Bundler](https://bundler.io), it locks down the full dependency graph in a file(`Cargo.lock`) ensuring deterministic builds.


## Alacritty

![]({{ 'img/awesome-rust-projects/alacritty.png' | asset_url }})


[Alacritty](https://github.com/jwilm/alacritty) is a cross-platform, GPU-accelerated terminal emulator. Utilizing the memory safety and excellent parallelism of Rust it's already the fastest terminal emulator available. This blog post was written in [Neovim](https://neovim.io/) running in [tmux](https://github.com/tmux/tmux) with Alacritty as the terminal emulator. In my experience so far Alacritty is a lot faster than iTerm which used to be my default choice for terminal emulation. Refreshingly Alacritty moves all configuration to a YAML file making it a lot simpler to sync configuration across many computers.

## tray_rust

[Will Usher's](https://twitter.com/_wusher) [tray_rust](https://github.com/Twinklebear/tray_rust) is a fast, fully featured ray tracer in Rust. Will also created a Rust port of the great C++ .obj loader [tinyobjloader](https://github.com/syoyo/tinyobjloader) called [tobj](https://github.com/Twinklebear/tobj). I've personally used and contributed to tobj as part of my much less impressive rust ray tracer.

