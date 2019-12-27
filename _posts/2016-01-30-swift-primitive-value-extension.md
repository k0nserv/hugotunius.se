---
layout: post
title: "Swift Primitive Value Extension"
categories: swift ray-tracing
date: 2016-01-30
---

Swift, unlike many other languages, does not separate primitive values from classes and structs.
As we'll see in this post this choice allows for some interesting and powerful constructs.
In other languages, such as Java, the primitive types `int`, `double`, `float`, and `boolean`
are distinctly different from classes and, because of that, you can't use them in the same way.

In Swift "primitive types" are actually structs which unlocks a lot of
interesting features that are otherwise not available for primitives. The code
in this post utilizes extensions to extend 32 bit integer values.

## Colors

A color is usually represented as a tuple of 3 or 4 values in the range 0, 255.
In OSX and iOS development we have `UIColor` and `NSColor`.

A straightforward way to implement a color value is shown below. It's
most likely similar to the `UIColor` and `NSColor` implementation.

{% highlight swift %}
// Example color implementation
struct Color {
  let r: UInt8
  let g: UInt8
  let b: UInt8
}
{% endhighlight %}

In lower level graphics programming it's common to pack color values into integer
values by doing bit manipulation. This is done primarily for memory efficiency
and compatibility with hardware. A framebuffer is commonly a 1 dimensional
array of ints with some kind of packing. There are different ways to pack a
color value into an int.

For example using a 32 bit unsigned integer
with 4 8 bit values. This packing is usually referred to as `ABRG`
for `Alpha`, `Blue`, `Green`, and `Red`. The alternative `RGBA` is also used.

[![]({{ 'img/swift-primitive-value-extension/32-bit-color.png' | asset_url }})](/img/swift-primitive-value-extension/32-bit-color.png)

`ABGR` packing is show in the image above.

In Swift rather than using a struct we can pack color values into integer values.
With extensions and typealiasing we can create something that behaves like a
struct while retaining the compact memory layout and speed of a packed integer.

{% highlight swift %}
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

typealias Color = UInt32

extension Color {
    var r: UInt8 {
        get {
            return UInt8((self & 0x000000FF) >> 0)
        }
    }

    var g: UInt8 {
        get {
            return UInt8((self & 0x0000FF00) >> 8)
        }
    }

    var b: UInt8 {
        get {
            return UInt8((self & 0x00FF0000) >> 16)
        }
    }

    var a: UInt8 {
        get {
            return UInt8((self & 0xFF000000) >> 24)
        }
    }

    init(r: UInt8, g: UInt8, b: UInt8) {
        self = 0xFF000000
        self = self | UInt32(r) << 0
        self = self | UInt32(g) << 8
        self = self | UInt32(b) << 16
    }
}
{% endhighlight %}

In other languages this pattern can still be used, but it requires that
everyone is a aware when a 32 bit int is actually a color and not a
normal int. The fact that Swift supports extensions of primitive types like this,
is extremely powerful and gives us type safety, information hiding, and auto
completion. Memory efficient layout is retained as well as comatibility with C APIS that expect arrays of ints as color values.

This code was written as a part of my [Swift
Ray tracer](https://github.com/k0nserv/SwiftTracer-Core). The full source of this
color packing is available [here](https://github.com/k0nserv/SwiftTracer-Core/blob/0bc150ba674a205889699e1b22477bbb736e60a5/Sources/SwiftTracerCore/Misc/Color.swift)
