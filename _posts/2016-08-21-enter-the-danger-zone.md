---
layout: post
title: "Enter the Danger Zone"
categories: clean-code ci dev-environment
date: 2016-08-21
description: >
  Some of my thoughts on the Danger gem and
  the work I've been doing on GitLab support
  for it recently.

---

Recently I've been working on [GitLab support](https://github.com/danger/danger/pull/299) for the [Danger](http://danger.systems/) gem. Danger is a gem that extends the concept of CI. She(yes the gem is referred to as she) tries to formalize your pull request etiquette by introducing automated checks for tasks commonly done by humans in code reviews/PRs. This leaves humans to think about more important and difficult things. As I've [written about before](https://hugotunius.se/2015/11/09/cleaner-code-with-strictness.html) having CI systems that are as strict as possible can be strong driver for code quality and long term project health. Removing burdens from humans makes Danger a double win. Naturally I'm a big fan of Danger.

Danger is written in Ruby and provides a lovely DSL for specifying tasks and checks. She will leave comments on your PR/MR with any errors, warnings or messages. The task and checks are stored in a `Dangerfile` in the root of your repository, this is just a ruby file. Here's a simple example of a small `Dangerfile` that enforces CHANGELOG entries for contributions.

{% highlight ruby line %}
# Add a CHANGELOG entry for app changes
if !git.modified_files.include?("CHANGELOG.md") && has_app_changes
  fail("Please include a CHANGELOG entry.")
  message("Note, we hard-wrap at 80 chars and use 2 spaces after the last line.")
end
{% endhighlight %}

You can also do things like enforce that branches are fully rebased, raise a warning if critical files are modified by a non core contributor. Truly though your imagination is the only limiting factor. She also supports plugins so you can write and share specific task, as an example there's the [rubopcop](https://github.com/ashfurrow/danger-rubocop) plugin by [Ash Furrow](https://ashfurrow.com/) that brings lint errors from rubopcop to the comments.

With support for GitLab I hope Danger can gain adoption in companies that run their own infrastructure instead of using public code hosting. I actually started working on GitLab support because I wanted to start using Danger internally at [Skyscanner](http://codevoyagers.com/). I have some interesting use cases that I'd like to try out now that GitLab is supported.

So if you have tasks that are done by humans(typically poorly) during Code Reviews give Danger a try. If you have any problems just raise an issue or ping me on [twitter](https://twitter.com/k0nserv). On an ending note I would be remiss if I didn't take this opportunity to include an Archer GIF.

![](http://media3.giphy.com/media/hWoDtMnsUYdVu/giphy.gif)
