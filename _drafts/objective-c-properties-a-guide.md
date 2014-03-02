---
layout: post
title:  "Objective-C properties, a guide"
categories: objective-c
---

Objective-C 2.0 introduced the property concept for the first time. Properties are objective-c constructs, declared with `@property`, that helps you control access to your instance variables. In this post I'll go through some techniques and best practices when using properties.

##Declaring properties
In its simplest form a property looks like this: `@property NSString *name`. This line publicly, limited to the scope of the interface, declares that two methods exists `- (void)setName:(NSString *)name` and `- (NSString *)name`. This pair of methods are commonly refered to as a setter and a getter in OOP languages. 

So, what happens under the hood of the that line? The property we just declared uses all the default settings it will be `atomic`, `strong` and `readwrite`. 

### "Thread safety"
The first setting, `atomic`, makes the setter and getter thread safe in the sense that the undelying variable will be guarded by a semaphore or mutex. In short this means that two threads accessing the same property will not interfer with each other. Naturally `atomic` properties are slower because of the overhead. Additionally you cannot override the setter or getter of an `atomic` property and maintain the "thread safety" guarantee. 

The other option is `nonatomic` it does not make any guarantee about thread saftey, however you can override the setter or getter. Overriding the setter and getter is very useful as well see.

### Ownership

The second setting, `strong`, specifies that the instance will `retain` the property. In short this mean that the property will not be dealloacted as long as the instance of our class is alive. The opposite of `strong` is `weak`. `weak` does not `retain` instead it uses `assign`, with `weak` the property can be deallocated at any point in time, even while our instance is still alive. `weak` is typically used for delegates, data sources and for UIViews in the view hierarchy. The third option is `copy`. `copy` acts the same as `strong` except it creates a copy of any element sent to the setter and then `retains` that copy.

> `copy` should be used for all classes that either are mutable or has a mutable counter part. For example `NSString` and `NSArray`. If you use `strong` it is possible to pass a mutable object and later change it behind your back, you don't want this to happen. As you can see the property we started out with is not safe because it uses `strong`.

### Access mode

Lastly `readwrite` simply specifies that we want both a setter and a getter for our property. The alternative is `readonly` in this case we only get a getter.

### Renaming the methods

Using either `getter=X` or `setter=X:` you can rename the declared methods.

### Dot notation

One of the major benefits of properties is dot notation. Dot notation lets you write `instance.propertyName` instead of `[instance propertyName]` and `instance.propertyName = value` instead of `[instance setPropertyName:value]`. Allways use dot notation. 


## Synthesizing properties

The `@property` keyword is used to declare that the property exists, however it does nothing more than that. To uphold the promises made by the property we use `@synthesize`. `@synthesize` creates the methods that the property declared.

> Since LLVM 4.0 the compiler will autosynthesize all your properties if you do not do it. Personally I still synthesize my properties explicitly.

To synthesize the variable property from above we add `@synthesize name;` in our `@implementation` section. This will create the methods `- (void)setName:(NSString *)name` and `- (NSString *)name` by default the underlying variable will be called `_name`. You should almost **never** use the underlying variables for your properties with the following exclusions:

+ When overriding the setter or getter
+ To initialize `readonly` variables in `init` methods
+ To avoid triggering side effects of setters or `KVO` when modifying the value internally

> If you are planning to override the getter or setter don't trust the autosynthesize use `@synthesize name = _name` to explicitly define the underlying variable for your property

## The simple rules

+ Always use dot notation
+ Always use the property except for the edge cases described in the synthesize section
+ Always specify `copy` for foundation classes which have a mutable interface
+ Always use explicit synthesizing if you are overriding the getter or setter
+ Prefer `readonly` for the public interface

## Overriding properties

### Lazy initialization

Lazy initialization is based around not initializing properties until they are used the first time, this is beneficial if there exist code paths were the property is never used.

<script src="https://gist.github.com/k0nserv/8984787.js"></script>

### Side effects

Overriding the setter can be used to introduce side effects when a property is updated. Having side effects on update of a property is generally not a good idea because it is confusing and unexcepted, but it is good in a small number of cases. The following example uses it to update a calculated variable when it's sub part update

<script src="https://gist.github.com/k0nserv/8985215.js"></script>




