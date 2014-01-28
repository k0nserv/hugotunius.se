---
layout: post
---

About a month ago a [post](http://news.ycombinator.com/item?id=6725387) on Hacker News featured an impressive spreadsheet implementation in less than 30 lines of javascript. The next day a collaborative fork in less than 45 lines of javascript was [submitted](https://news.ycombinator.com/item?id=6730084). By now I think most people will agree that javascript is a powerful language with a wide array of use cases and feats like these only strengthen that standing further. Let's pause for a second and look at how it is possible to create these wonders of javascript.

Wanting to try my hand at some javascript code golf I implemented a [graph plotter](http://codepen.io/k0nserv/pen/GbmAC) in 14 lines of javascript. I noticed that the two very frowned upon features [with](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/with) and [eval](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval) were essential to achieve as few lines as possible. The are also present in the spreadsheet implementations.

`eval` of course evaluates and runs any code passed to it as a string as does its less evil cousin the [Function](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function#Syntax) constructor. In the graph plotter I used the `Function` constructor to create the mathematical function used to compute the corresponding `y` values for each `x`.

<script src="https://gist.github.com/k0nserv/8176804.js"></script>

In the above snippet the usage of `with` is also included. `with` modifies the scope chain used for lookup of unqualified names in the scope of with. Here's an example

<script src="https://gist.github.com/k0nserv/8180757.js"></script>

Together `math` and all variations of `eval` create the potential for disasters in security, undefined behaviour and bugs. The with statement even comes with the following warning on [MDN](https://developer.mozilla.org/en-US/):

>Use of the with statement is not recommended, as it may be the source of confusing bugs and compatibility issues. See the "Ambiguity Con" paragraph in the "Description" section below for details.

However as seen in the code golf exercises above they are extremely powerful and that is also their problem, they are too powerful to be trusted.

