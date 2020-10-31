---
layout: post
title:  "Flutter Web: A Fractal of Bad Design"
categories: cross-platform web html css opinion
date: 2020-10-31
description: >
  How a misguided attempt to achieve cross platform UI leads to terrible experiences and kills the open web
---

The web has a long and rich history dating back to the nineties at CERN. Back then [Tim Berners-Lee](https://twitter.com/timberners_lee) laid the foundation of HTML that is still around today. There have been attempts to replace it with varying success but none have been successful, for good reason. HTML and the later invention of CSS are a remarkably powerful set of tools to build all kinds of experiences on the web. People are still trying to replace HTML, which brings us to the topic of this post: Flutter Web.

[Flutter Web](https://flutter.dev/web) is part of Google's [Flutter](https://flutter.dev/) framework for building cross platform UI. Hailed by many developers as the best thing since sliced bread, my opinion of it lacks the rose coloured glasses. I haven't looked at Flutter for other platforms than web so I cannot comment on it other than that the general principle of Flutter is a terrible idea. Flutter works by throwing away the native UI toolkits provided by the platform and rendering everything from scratch using OpenGL et al. This translates extremely poorly to the web platform in particular. It's worth noting that Flutter for Web is currently in beta and the problems I am about to detail could be addressed. However, I believe these issues are fundamental to Flutter's design choices so I feel confident in my criticism.

## Semantic HTML

Anyone learning HTML these days would have encountered the term "Semantic HTML" because it is such an important part of modern web. [Peter Lambert](https://www.petelambert.com/) describes why this is important in the excellent blog post [HTML is the Web](https://www.petelambert.com/journal/html-is-the-web). In short, the visible portion of a website, i.e. presentation, is only half the story. To take an example Peter used, a `div` with an `onClick` handler might be clickable and can be styled to look like a button, but that doesn't make it a button. The semantic structure of a document matters because that's how machines, not humans, understand the web. A `div` with an `onClick` handler doesn't look like a link or a button to a screen reader, search engine crawler, or accessibility extension, it looks like a `div`.

Most importantly, semantic HTML is key for accessibility and other tools that let a user experience the web as they wish.

## A Fractal of Bad Design

Does Flutter Web generate semantic HTML? Not even close. It generates a patchwork of `canvas` elements, custom elements, and a few other HTML elements. In the demo app [Reply](https://gallery.flutter.dev/#/reply), how many buttons and links are there? If you guessed **zero**, congratulations you are as jaded and cynical as me. Let me reiterate that, an email app with no buttons and links! Because there are no links in particular, features like cmd/ctrl clicking to open a new tab, hovering links to see the URL, and using the context menu do not work.

I use the browser extension [Vimium](https://vimium.github.io/) to navigate the web, it's an amazingly powerful tool that relies on, you guessed it, semantic HTML. Does it work on pages built with Flutter Web? Fuck no. It doesn't work because it tries to find things that are semantically clickable, like `button` or `a` elements, of which, as we have established, Flutter Web generates none. Vimium works on almost all websites I use because most developers, thankfully, don't just stick `onClick` handlers on `div`s. However, whatever crazy shit Flutter Web does, doesn't look clickable. Things being clickable that don't look clickable is a good proxy for poor accessibility. For example, screen readers can navigate by landmarks, such as headings, **links**, forms, and other semantic elements, does any of this work with Flutter Web? Fuck no.

Even worse, unless you use special "selectable" text, Flutter Web doesn't even support selecting text. No joke, their own code examples have a "copy all" button to get around this.

[![Screenshot of Flutter's Navigation Bar component with preview, code, and "copy all" button]({{ 'img/flutter-web-a-fractal-of-bad-design/code-example.png' | asset_url }})](/img/flutter-web-a-fractal-of-bad-design/code-example.png)

How did anyone look at this and say "yeah nah, selecting text isn't an important use case on the web"? Why does selecting text matter you ask? Some people use it to aid with reading by selecting the text they are currently reading, other people use it to(and I know this is wild) copy parts of the text, people with dyslexia use tools that read out selected portions of the text to help them read. Does any of this work with Flutter's default, unselectable text? Fuck no!

While we are talking about dyslexia, another useful feature that help people who suffer from it is the ability to change the fonts of web pages to one they find easier to read, such as [OpenDyslexic](https://www.opendyslexic.org/). There are many tools that help with this and they all rely on the ability to inject custom CSS in a web page, to my surprise this actually looked to work when I tried it on some of the Flutter Web demos. However, looks deceive and while the font does apply it causes text to get cut off in almost all instances because of the terrible HTML Flutter generates. For example, in the "Reply" email client here's the tag for the word "Reply" in the upper right

{% highlight html %}
<p style="font-size: 18px; font-weight: normal; font-family: WorkSans_regular, -apple-system, BlinkMacSystemFont, sans-serif; color: rgb(255, 255, 255); letter-spacing: 0px; position: absolute; white-space: pre-wrap; overflow-wrap: break-word; overflow: hidden; height: 27px; width: 54px; transform-origin: 0px 0px 0px; transform: matrix(1, 0, 0, 1, 59, 3.5); left: 0px; top: 0px;">REPLY</p>

{% endhighlight %}

Cleaned up a bit and these are the attributes

{% highlight plain %}
font-size: 18px;
font-weight: normal;
font-family: WorkSans_regular, -apple-system, BlinkMacSystemFont, sans-serif; color: rgb(255, 255, 255);
letter-spacing: 0px;
position: absolute;
white-space: pre-wrap;
overflow-wrap: break-word;
overflow: hidden;
height: 27px;
width: 54px;
transform-origin: 0px 0px 0px;
transform: matrix(1, 0, 0, 1, 59, 3.5);
left: 0px;
top: 0px;
{% endhighlight %}

Flutter Web generates absolutely positioned fixed sized HTML which instead of adopting to the text layout specified by the browser just cuts the text off.


Another useful feature that is common in accessibility extensions is making links stand out more. This works by injecting global CSS rules that target `a` tags on the page.

[![Screenshot of links with link emphasis turned on which underlines them in multiple colours]({{ 'img/flutter-web-a-fractal-of-bad-design/link-underlines.png' | asset_url }})](/img/flutter-web-a-fractal-of-bad-design/link-underlines.png)

Does this work with Flutter Web (this questions is starting to feel redundant because the answer is almost always "No")? Fuck no! In general, users use custom stylesheets for a multitude of reasons not limited to accessibility. As a "fun" exercise try this [low vision stylesheet](https://ssb22.user.srcf.net/css/) on one of the [Flutter Web demos](https://gallery.flutter.dev/) and see how readable the content is.

Another one of the [demos](https://gallery.flutter.dev/#/fortnightly) in the Flutter Web Gallery is a news site. On news sites, I like to use the built-in "reader mode" in my browser to get a reading experience that is free from clutter and better suites me. For example, when reading in bed late at night (which I know I shouldn't do) it's nice to have a soft, dark mode experience instead of the glaring black text on pure white that many publications use. Does reader mode work with Flutter Web website? Nope. It doesn't work because, you guessed it, it relies on semantic HTML.


[![Screenshot of Firefox accessibility inspector showing a single button with the text "Enable accessibility"]({{ 'img/flutter-web-a-fractal-of-bad-design/enable-accessibility.png' | asset_url }})](/img/flutter-web-a-fractal-of-bad-design/enable-accessibility.png)

Like any good writer, I've saved the best for last: the screen reader experience with Flutter Web. When you first focus on  one of the Flutter Web demos with a screen reader you are greeted with a "button" that says "Enable accessibility". Admittedly, when you click this button there is a resemblance of screen reader content but it's terrible. In the "Reply" app things are read out with unnecessarily high detail in the list view, things that can be clicked aren't identified as such, you cannot even get to the menu as far as I can tell, and as previously identified there are almost no landmarks which are used for navigation.

## Conclusion

Flutter is a misguided attempt to achieve the impossible: quality cross platform experiences. Flutter Web in particular is fundamentally flawed and needs to be rebuilt from the ground up if it has any hopes of being viable tech that generates semantic, accessible, and modern web experiences. I have serious doubt that when Flutter Web leaves beta any of this will be addressed properly, unless the whole approach is reconsidered. If you see Flutter Web, turn around and run in the opposite direction.

Developers, designers, and product people all love cross platform solutions because it saves them time and energy while achieving the "same" outcome as the costlier alternatives. Flutter Web nicely illustrates that the outcomes aren't the same, the visible part of a product is only one part of the puzzle.

I'm merely an accessibility novice and I didn't even mention SEO in this post. I didn't stop writing because I stopped finding flaws, but because this post was getting too long and I have other things to do. I'm sure accessibility users and experts can find even more issues than I have presented here(feel free to DM me on [Twitter](https://twitter.com/k0nserv) and I'll include them).

To end I'd like to leave you with a [quote](https://www.youtube.com/watch?v=mRNX6XJOeGU) from [Dr. Ian Malcolm](https://www.imdb.com/title/tt0107290/characters/nm0000156?ref_=tt_cl_t3).

> Your scientists were so preoccupied with whether or not they could, they didn’t stop to think if they should.
