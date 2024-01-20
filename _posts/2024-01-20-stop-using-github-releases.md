---
layout: post
title: "Stop Using (only) GitHub Releases"
date: 2024-01-20
categories: programming culture git vsc ux opinion
description: >
    A rant on the practice of storing release notes in GitHub's release features and the negative consequences of that
---

The other day at work I, accidentally, roped myself into upgrading some dependencies in our Rust services. These were breaking changes, so not just a case of running `cargo update`. I had to understand the changes and make the appropriate modifications to our code. Adopting breaking changes can be frustrating in the best of times, but it was particularly annoying this time because none of these projects kept a `CHANGELOG.md` files, although they all had release notes on GitHub. 

GitHub's [releases feature](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository) allows you to combine a git tag with release notes, metadata, and files(binaries, source code etc). While useful, GitHub's releases have many downsides and consuming them adds friction to the task of understanding changes in a project. They can be a useful supplement to a `CHANGELOG.md`/`HISTORY.md`/`RELEASES.md` file but **should not** be the only place where release notes are recorded.

The problems with exclusively using GitHub's releases feature are:

**Pagination**, which makes it hard to search across the full releases and makes cross-referencing between different versions cumbersome.

**Not truly being apart of the repository**, which means, if you want to look at the source checked out, you end up having to read release notes on `github.com` and the source in your editor(reading the code on GitHub is not ergonomic at all).

**External system risk**, which means that an integral part of the project, the release notes, live in an external system to the code itself. While GitHub is showing no signs of waning at the moment, it's not going to be around forever and when it does eventually fall out of favour the release notes of many projects will be lost to history. Migrating the git repository itself to a new host is trivial and necessary, but few projects will take the time to migrate release notes. Of course, a `CHAGNELOG.md` file(already being apart of the repository) migrates along the source code.


If you are involved with an open source project, please do [keep a changelog](https://keepachangelog.com/en/1.1.0/), but make it an actual file in the repository not just the releases section on GitHub. If you provide release notes on GitHub in addition to the file that's great too!

This idea generalises beyond just release notes. Always try to make the source of truth files in git, rather than data in the databases of external system. Don't relegate the details of why a change was made to an external ticketing system, that will eventually be lost to history, put them in the commit message. Don't put your documentation in an external system that will get lost when the business changes its mind about documentation practices for the hundredth time, put it in markdown files in a folder. If something is related to development of a project and can be expressed as files in a folder, it should be files in a folder.

> If something is related to development of a project and can be expressed as files in a folder, it should be files in a folder.

