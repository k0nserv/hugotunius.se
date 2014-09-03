---
layout: post
title:  "Custom Control Structures in Swift"
categories: swift ios xcode
---
Apple's new language `Swift` has some really nice syntactic sugar for common operations. One of the new features is closures which are similar to blocks in Objective-C, but they have a few tricks that blocks don't have. When the last argument to a function is a closure it's possible to put it outside the parenthesis of the call to the function. This makes it possible to write control structures which look(almost) identical to the normal control structures.

### Reimplementing the if-statement
Let's use these trailing closures to reimplement the if-statement
{% highlight swift line linenos %}
func _if(condition: BooleanType, action: () -> ()) {
  if condition {
    action()
  }
}

_if(1 < 2) {
  println("1 is less than 2")
}
{% endhighlight %}

The second argument to the function `_if` is a closure with no parameters and no return value. It has the type `() -> ()`. Because the last argument is a closure it can be moved outside of parenthesis that make up the method call. Unfortunately we still need to parenthesis to invoke the function which is not the case for the real if statement, but we can just pretend this is `C`.

> The `BooleanType` is a protocol that can be adopted to allow any type to work with the various control structures in the language such as if and while

#### If without if
There is a problem with the `_if` function though - it uses the `if` statement which makes it extremely redundant and unimaginative. Could we implement it without using the `if` keyword? Yes we can.

{% highlight swift line linenos %}
func _if_without_if(condition: BooleanType, action: () -> ()) {
    // We fake the false case by using an empty closure, e.g a NOP
    let actions = [{}, action]

    // boolValue returns a Bool and we can abuse the fact that
    // hashValue of true is 1 and then hashValue of false is 0 to
    // get the correct closure to run
    actions[condition.boolValue.hashValue]()
}

_if_without_if(1 < 2) {
    println("1 is less than 2 even without if")
}
{% endhighlight %}

> This is the solution I came up with, but I'd love to see more ways of doing it.

### Reimplementing the while-statement

How about while? Can we implement it in the same way?
{% highlight swift line linenos %}
func _while(condition: @autoclosure () -> BooleanType, action: () -> ()) {
  while condition() {
    action()
  }
}

var i = 0
_while(i < 10) {
  println("\(i)")
  i += 1
}
{% endhighlight %}

Here I am using a Swift feature called auto closure which wraps any expression passed in a closure. This is why the condition is prefixed with `@autoclosure`. Without this there would be no way to reevaluate if the condition had changed as a cause of the loop body, we would have an infinite loop or no loop at all. Again we can use the trailing closure syntax to closely emulate the native `while`.

#### While without while
Again the `_while` function is cheating and uses the `while` statement to accomplish it's function. Here's my solution without using `while`.

{% highlight swift line linenos %}
func _while_without_while(condition: @autoclosure () -> BooleanType, 
                          action: () -> ()) {
  var loop: () -> () = { $0 }
  loop = {
    // The condition is called each time to 
    // see if the loop should continue
    if condition() {
      // Then the acutal action is called
      action()

      // Lastly the closure calls itself recursively
      loop()
    }
  }

  // This sets off the first loop iteration
  loop()
}

var j = 0

_while_without_while(j < 10) {
  println("\(j)")
  j += 1
}
{% endhighlight %}

### Useful examples

The examples shown above are nothing but hacks for the sake of fun. Let's now look at some examples of control structure which are more useful. Starting with a something that ruby and perl programmers will recognize, `unless`.

#### Unless

`unless` is a keyword found in ruby and perl. It's essentially a reverse if statement which will branch if the condition is false.

Here it is in swift
{% highlight swift line linenos %}
func unless(condition: BooleanType, action: () -> ()) {
  if condition.boolValue == false {
    action()
  }
}

var opt: Int? = 10
unless(opt == nil) {
  println("opt was non nil")
}
{% endhighlight %}
Ruby programmers might miss the infix version of this keyword which looks like this `action unless condition`. Well thanks to Swifts operators we can implement that too, albeit without the nice name.

{% highlight swift line linenos %}
// Define the ++= operator
infix operator ++= {}
func ++= (action: @autoclosure () -> (), condition: BooleanType){
  unless(condition, action)
}

var x = 1

// This is equal to ruby's
// x = 2 unless 1 > 2
(x = 2) ++= 1 > 2

println("\(x)")
{% endhighlight %}
>Don't do do that in real code though. Operator overloading and definition should be used sparsely.

#### Maybe

Imagine you are writing a game and want something to happen sometimes. For that there's the `maybe` operator which executes the specified action 50% of the time.

{% highlight swift line linenos %}
// Perform some action 50% of the time
func maybe(action: () -> ()) {
  if arc4random_uniform(2) == 0 {
    action()
  }
}

maybe {
  println("Hello World?")
}
{% endhighlight %}
#### Threads

As most iOS developer learn the hard way modifying the UI from any thread but the main thread is not a good idea. This task is so common that it deserves a control structure. As does the task of performing a task in the background.

{% highlight swift line linenos %}
func onMainThread(action: () -> ()) {
  dispatch_async(dispatch_get_main_queue(), action)
}

onMainThread {
  myView.hidden = true
}

func inBackground(action: () -> ()) {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), action)
}

inBackground {
  fetchDataFromInternet()
}
{% endhighlight %}

### Discussion

After posting this post some interesting discussion was brought up. Reddit user [drewag](http://www.reddit.com/user/drewag) pointed out that the return statement doesn't play very nicely with these custom control structures because it will simply return from the closure rather than returning from the enclosing function. This is in part mitigated by the fact that the return has to be a void return to not cause a compiler error. Still it's good to keep in mind.

[@Fudmottin](https://twitter.com/Fudmottin) pointed out the similarity to [Common Lisp Macros](http://cl-cookbook.sourceforge.net/macros.html). He also went ahead and tried his hand at implementing a `do...until` control structure which I used as a base to build my own implementation.

{% highlight swift line linenos %}
// The DoUntil struct holds the action that is
// the loop body
struct DoUntil {
  let action: () -> ()

  init(action: () -> ()) {
    self.action = action
  }
  
  // Using a method like this allows replacing what would have
  // been a space in 
  // do {
  //    println("i = \(i)")
  //    i++
  // } until (i == 10)
  // with a dot instead
  func until(condition: @autoclosure () -> BooleanType) {
    while condition().boolValue == false {
      action()
    }
  }
}

func Do(block: () -> ()) -> DoUntil {
  return DoUntil(action: block)
}

i = 0

Do {
  println("i = \(i)")
  i++
}.until(i == 10)

i
{% endhighlight %}

A few people also weighed in on whether this is a good idea in practice. For now I consider it a good demonstration of Swift's capabilities which, when used correctly make for powerful semantic tools.

Join the discussion on [Reddit](http://www.reddit.com/r/swift/comments/2e0s41/custom_control_structures_in_swift/)