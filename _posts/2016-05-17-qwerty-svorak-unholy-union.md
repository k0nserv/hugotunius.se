---
layout: post
title: "An Unholy Union Between QWERTY and Svorak"
categories: dev-environment
date: 2016-05-17
description: >
  My interesting keyboard layout.
  The result of an unholy union
  between QWERTY and Svorak.
---

Like many programmers not from the US I grew up and
learned programming on a rather suboptimal keyboard layout.
When I started programming at 14 I didn't think much about the
keyboard, sure typing `{` involved pressing the extremely awkward
combination `alt+shift+8` and sometimes shortcuts would not work
because the author didn't consider layouts outside of US QWERTY,
I however was still happy.


It wasn't until my second year in university
that I started thinking about keyboard layouts and how suboptimal
Swedish QWERTY is for the act of programming. I had friends that
embraced the Swedish variant of Dvorak, called Svorak. I tried it out, but ultimately I decided that learning it was not
worth the effort. However I did like the way that [Svorak A5](http://aoeu.info/s/dvorak/svorak)
treated access to modifiers often used in programming by placing them
under the regular letters using the `alt` modifier.

![]({{ 'img/keyboard-layout/svorak-A5.png' | asset_url }})

After switching back to Swedish QWERTY I missed how presing
alt would give you access to modifiers in A5. `{` was as easy as `alt+q`
and `;` was `alt+a`. When I grew more frustrated with this I started
wondering if it wouldn't be possible to combine Swedish QWERTY and Svorak
somehow. I found the program [Ukelele](http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=ukelele)
and created the first version of this unholy union. Now I could
feel comfortable writing text as well as programming. In the beginning
I struggled to wean myself of the old QWERTY modifiers so I modified
the layout to remove the option completely.
Below is a video of how this works in reality.

<video src="{{ 'img/keyboard-layout/optimized.mp4' | asset_url }}" controls></video>

If you have a mac and want to try out this layout use

{% highlight shell %}
$ curl https://hugotunius.se/files/qwerty_forced_dvorak.keylayout > ~/Library/Keyboard\ Layouts/qwerty_forced_dvorak.keylayout
{% endhighlight %}

and add it as a input source under System Preferences > Keyboards.
