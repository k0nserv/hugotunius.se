---
layout: post
title: "Making Invalid State Unrepresentable"
categories: code swift rust clean-code
date: 2020-05-16
description: >
  On the importance of correctly modelling state in a way that makes invalid state Unrepresentable and how different languages help or not.

---

Software bugs often happen when the internal state of a program is invalid or inaccurate. As programmers our job is to manage state while avoiding these bugs. So how can we avoid invalid state? Well for one we could try to eliminate all state in our programs, but this approach quickly falls apart if we want to write useful software. A better approach is to make it impossible to introduce invalid state by preventing it from being represented.

What does it mean to only be able to represent valid state? It's the idea that all state that can be represented in our program is valid state for our domain.

For example when deciding on the type that represents the length of a collection we can use an unsigned word sized value. By definition the length of a collection cannot be negative, by picking an unsigned value we've ensured this invalid state(a collection with negative length) cannot be represented. Not all programming languages will help us avoid other invalid state that can arise from this choice. C++ does not prevent you from initializing an unsigned integer(`uint`) with the value `-1` and Java doesn't have a unsigned numbers at all. Rust and Swift on the other hand rightfully tell you that trying to create an unsigned integer with the value `-1` is nonsensical. Dynamically typed languages can only provide runtime feedback when we have introduced invalid state which is too late because the invalid state is now a bug.

Let's consider two concrete cases of invalid state that are common and where the choice of programming language dictates if we can make the invalid state unrepresentable.

## Absence

A value being absent is often valid state. Every person was born on a specific date but not all people have died yet, let's model a person in Java.

{% highlight java %}
import java.util.Date;


public class Person {
  private Date birthday;
  private Date deathday;

  Person() {
    this.birthday = null;
    this.deathday = null;
  }

  void setBirthday(Date birthday) {
    this.birthday = birthday;
  }

  Date getBirthday() {
    return this.birthday;
  }

  void setDeathday(Date deathday) {
    this.deathday = deathday;
  }

  Date getDeathday() {
    return this.deathday;
  }
}
{% endhighlight %}

Now let's consider the states an instance of `Person` can be in.

|  State                            |  Valid |  Representable |
|-----------------------------------|--------|----------------|
| birthday = null, deathday = null  | ❌      | ✅              |
| birthday = Date, deathday = null  | ✅      | ✅              |
| birthday = Date, deathday = Date  | ✅      | ✅              |
| birthday = null, deathday = Date  | ❌      | ✅              |

That's no good, **half** the states a given instance of `Person` could be in are invalid. Let's see if we cannot make this better.

{% highlight java %}
import java.util.Date;
import java.util.Optional;


public class Person {
  private Date birthday;
  // 1
  private Optional<Date> deathday;

  // 2
  Person(Date birthday) {
    this.birthday = birthday;
    this.deathday = Optional.empty();
  }

  void setBirthday(Date birthday) {
    this.birthday = birthday;
  }

  Date getBirthday() {
    return this.birthday;
  }

  void setDeathday(Optional<Date> deathday) {
    this.deathday = deathday;
  }

  Optional<Date> getDeathday() {
    return this.deathday;
  }
}
{% endhighlight %}

By making two changes we've drastically improved the situation.

|  State                                              |  Valid |  Representable |
|-----------------------------------------------------|--------|----------------|
| birthday = Date, deathday = Optional<Date>.empty() | ✅      | ✅              |
| birthday = Date, deathday = Optional<Date>.of(Date) | ✅      | ✅              |

We changed(1) the type of `deathday` to `Optional<Date>` to make it clear that it's optional and we enforced(2) setting a value of `birthday` by requiring it in the constructor. Job done, right? Not quite.

Because this is Java we can still use `null` even though I glossed over that fact in the above table.

|  State                                              |  Valid |  Representable |
|-----------------------------------------------------|--------|----------------|
| birthday = null, deathday = null                    | ❌      | ✅              |
| birthday = null, deathday = Optional<Date>.empty()  | ❌      | ✅              |
| birthday = null, deathday = Optional<Date>.of(Date) | ❌      | ✅              |
| birthday = Date, deathday = null                    | ❌      | ✅              |
|  birthday = Date, deathday = Optional<Date>.empty() | ✅      | ✅              |
| birthday = Date, deathday = Optional<Date>.of(Date) | ✅      | ✅              |

Now two thirds of the states a `Person` could be in are invalid, that's not an improvement. Unfortunately with Java this is far as we can get. While the use of `Optional<Date>` to indicate that `deathday` can be absent while `birthday` should always be present is an improvement we can still create invalid states because of `null`.

Let's look at the same thing in Swift

{% highlight swift %}
import Foundation

struct Person {
  var birthday: Date

  // `?` is syntactic sugar, the type of
  // `deathday` is `Optional<Date>`
  var deathday: Date?

  init(birthday: Date) {
    self.birthday = birthday
  }
}
{% endhighlight %}

In Swift we have achieved what we set out to do. Only valid states are representable, there's no way to construct an instance of `Person` that has no value for `birthday` but does have a value for `deathday`.


|  State                                                |  Valid |  Representable |
|-------------------------------------------------------|--------|----------------|
|  birthday = Date, deathday = Optional<Date>.none      | ✅      | ✅              |
| birthday = Date, deathday = Optional<Date>.some(Date) | ✅      | ✅              |

Why does Swift not suffer from the same problem as Java? Because Swift does not have `null` references and in fact `Optional` is a value type that cannot be referenced. The Swift compiler requires values to be initialized before use so there's no way to forget to initialize a value and the lack of `null` references means we have to use `Optional<T>` to model the absence of a value.

## Mutually exclusive state

Often state can be in one of **n** states, the simplest example of this is a boolean which can be either `true` or `false` but not both at the same time. The `Optional<T>` type is another case like this, it's either some value or nothing/empty.

Imagine calling a remote API over HTTP. There are two outcomes: The call succeeds and returns some data or something goes wrong resulting in an error. Let's look at a callback based API of this type in Swift.


{% highlight swift %}
func makeHTTPCall(
  parameters: Parameters,
  callback: (SuccessValue?, Error?) -> Void
) {
 // omitted
}
{% endhighlight %}

The callback can be called with four different states of which two are invalid.

|  State                                             |  Valid |  Representable |
|----------------------------------------------------|--------|----------------|
| (Optional.none, Optional.none)                     | ❌      | ✅              |
| (Optional.some(SuccessValue), Optional.none)       | ✅      | ✅              |
| (Optional.none, Optional.some(Error))              | ✅      | ✅              |
| (Optional.some(SuccessVale), Optional.some(Error)) | ❌      | ✅              |

It doesn't make sense for the call to neither succeed nor error and likewise it cannot both succeed and error at the same time, yet these options are both representable in our state. The two options are mutually exclusive. Here we can use Swift's sum types and specifically the [`Result`](https://developer.apple.com/documentation/swift/result) type to model the mutually exclusive nature of the result of our HTTP call.

{% highlight swift %}
func makeHTTPCall(
  parameters: Parameters,
  callback: (Result<SuccessValue, Error>) -> Void
) {

  // Omitted
}
{% endhighlight %}

With this approach we have eliminated the two invalid states, they can no longer be represented.

|  State                       |  Valid |  Representable |
|------------------------------|--------|----------------|
| Result.success(SuccessValue) | ✅      | ✅              |
| Result.failure(Error)        | ✅      | ✅              |

## Conclusion

The idea of making invalid state unrepresentable is a powerful tool to avoid bugs by making the invalid state that causes them impossible. It works equally well when working along as it does in a team. By encoding more of our domain into the types of our program we not only make invalid state unrepresentable we also make it clear what valid state is.

Not all languages are equal in how well they help the programmer in making invalid state unrepresentable. The two core features of a language that I find particularly useful in this endeavour are: disallowing uninitialized values/supporting value types and sum types which can carry values. It's maybe not too surprising that my two favourite languages are [Swift](https://swift.org/) and [Rust](https://www.rust-lang.org/) while Java ranks far from being my favourite.
