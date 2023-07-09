---
layout: post
title: "The Great Pendulum"
categories: opinion web
date: 2023-07-09
description: >
   On the great pendulum that hides in the tech industry 
---

17 odd years ago when I stared programming, PHP was all the rage. Javascript was steadily gaining traction. Django and Ruby on Rails were in their infancy, but promised greatly increased productivity. A few years later, inspired by Ruby's fame, Coffeescript became a mainstay in the Javascript ecosystem. Statically compiled, typed languages, used to build monolithic web applications, were rapidly falling out of favour. In 2023 the trend is reversing, static compilation and types are cool again. Monoliths are making a comeback. _The pendulum is turning._

The first serious web application I built used an emerging pattern, AJAX(**A**synchronous **J**avascript **a**nd **X**ML), where the server didn't just return HTML, but also Javascript that could fetch further data and update the HTML later. Several years later, when many started complaining about the high cost of React and SPAs I started thinking in terms of the pendulum. Entirely server rendered applications is one extreme of this particular pendulum, entirely client side rendered applications being the other. In the pursuit of web applications that delivered snappier user experiences the industry, arguably, overshot past the equilibrium point. [HTMX](https://htmx.org/) and [Hotwired](https://hotwired.dev/) are examples of the pendulum starting to swing back, whether the industry will again overshoot is an open question.

There are many pendulums in our industry, here are some that I've noticed over the years:

* **Static typing** vs **Dynamic typing**.
* **Monoliths** vs **Microservices**.
* **Cloud** vs **On-prem**, I think on-prem is having a bit of a moment after the industry indexed heavily on cloud in the past decade.
* **Statically compiled languages** vs **Interpreted languages**.
* **Server Side Rendering** vs **Client Side Rendering**.

Those who have spent longer than me in the industry have, undoubtedly, spotted even more than I have. If you have a suggestion I would love to hear it.

## Conclusion

In most instances the correct position lies somewhere near the equilibrium point, but we tend to overshoot it in each swing. Maybe, like a real pendulum, the amplitude of these pendulums will decrease over time and they will come to rest at the equilibrium. Or maybe we'll continue to overshoot, the memories of the previous swing faded by time. I'm somewhat hopeful that we will learn from each period and the former will prove to be more true than the latter.
