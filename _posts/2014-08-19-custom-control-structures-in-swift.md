---
layout: post
title:  "Custom Control Structures in Swift"
categories: swift ios xcode
---
Apple's new language `Swift` has some really nice syntactic sugar for common operations. One of the new features is closures which are similar to blocks in Objective-C, but they have a few tricks that blocks don't have. When the last argument to a function is a closure it's possible to put it outside the parenthesis of the call to the function. This makes it possible to write control structures which look(almost) identical to the normal control structures.

### Reimplementing the if-statement
Let's use these trailing closures to reimplement the if-statement
<script src="https://gist.github.com/k0nserv/0daa2c8c27d1239c97be.js"></script>
The second argument to the function `_if` is a closure with no parameters and no return value. It has the type `() -> ()`. Because the last argument is a closure it can be moved outside of parenthesis that make up the method call. Unfortunately we still need to parenthesis to invoke the function which is not the case for the real if statement, but we can just pretend this is `C`.

> The `BooleanType` is a protocol that can be adopted to allow any type to work with the various control structures in the language such as if and while

#### If without if
There is a problem with the `_if` function though - it uses the `if` statement which makes it extremely redundant and unimaginative. Could we implement it without using the `if` keyword? Yes we can.
<script src="https://gist.github.com/k0nserv/b24f66cfac4c4b082793.js"></script>

> This is the solution I came up with, but I'd love to see more ways of doing it.

### Reimplementing the while-statement

How about while? Can we implement it in the same way?
<script src="https://gist.github.com/k0nserv/d62c248ad2e8c0173297.js"></script>
Here I am using a Swift feature called auto closure which wraps any expression passed in a closure. This is why the condition is prefixed with `@autoclosure`. Without this there would be no way to reevaluate if the condition had changed as a cause of the loop body, we would have an infinite loop or no loop at all. Again we can use the trailing closure syntax to closely emulate the native `while`.

#### While without while
Again the `_while` function is cheating and uses the `while` statement to accomplish it's function. Here's my solution without using `while`.
<script src="https://gist.github.com/k0nserv/920e2a35be9e41cd7d26.js"></script>

### Useful examples

The examples shown above are nothing but hacks for the sake of fun. Let's now look at some examples of control structure which are more useful. Starting with a something that ruby and perl programmers will recognize, `unless`.

#### Unless

`unless` is a keyword found in ruby and perl. It's essentially a reverse if statement which will branch if the condition is false.

Here it is in swift
<script src="https://gist.github.com/k0nserv/7a475a2812b48dbf4485.js"></script>
Ruby programmers might miss the infix version of this keyword which looks like this `action unless condition`. Well thanks to Swifts operators we can implement that too, albeit without the nice name.
<script src="https://gist.github.com/k0nserv/633bcc3ea2ff0ee4bc2d.js"></script>

>  Don't do do that in real code though. Operator overloading and definition should be used sparsely.

#### Maybe

Imagine you are writing a game and want something to happen sometimes. For that there's the `maybe` operator which executes the specified action 50% of the time.

<script src="https://gist.github.com/k0nserv/94d5645d806cd9873ab5.js"></script>

#### Threads

As most iOS developer learn the hard way modifying the UI from any thread but the main thread is not a good idea. This task is so common that it deserves a control structure. As does the task of performing a task in the background.

<script src="https://gist.github.com/k0nserv/30ed0869da1e2d060872.js"></script>

Join the dicussion on [Reddit](http://www.reddit.com/r/swift/comments/2e0s41/custom_control_structures_in_swift/)