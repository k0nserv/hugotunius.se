---
layout: post
title:  "Cleaner code with strictness"
categories: clean-code code CI 
redirect_from: /clean-code/code/ci/2015/11/09/the-one-weird-trick-to-write-clean-code.html
---

Writing clean majestic code is something I think we should all strive for in our work and it is important to me. The age-old _Code is read more than it is written_ is a good reason to be writing clean code. This post is about how I have found strictness to be a great tool in the effort to write clean code.

<!--- more --->

I think most developers strive to write clean code and that they take pride in the code they write. Even with this good intention there is a large amount of not so clean code being written everyday. I have definitely written my fair share of it. For me it all comes down to being human. I have good intentions, but somewhere between deadlines and hammering out a solution to the problem those good intentions were lost or forgotten. However who are better at remembering and enforcing things than our computers? With their aid we can all write cleaner code without thinking about it. 

With strictness I mean failing builds and CI. Automated tools are worthless if we allow ourselves to ignore their warnings. 

### Warnings
_"Listen to your compiler"_

The compilers that build our human readable source code into the bits and bytes of machine code have evolved to be extremely advanced tools with great knowledge about how our code will run on the target machine. In many regards the compilers are much smarter than us, so why is it that we continuously ignore their warnings? A build error is the compiler telling us _This is impossible_ and a warning is the compiler telling us _This is not a good idea_. I don't think it's our place to argue with the compiler because in almost every case the compiler knows best. 

Because I acknowledge that the compiler is probably right when it warns me about something the first thing I do before starting a project, even before the first line is written, is to treat warnings as errors and turn on most if not all warnings.

> `-Wall -Werrors` is good for you

### Linters and Static Analyzers
_"Readability über alles"_

While the compilers are really good at reasoning about our code and any potential bugs in it, they are not good at all at reasoning about the readability of our source code. To the compilers the following programs are the same 

{% highlight C line %}
#include<stdio.h>
int main(void){printf("Hello World"); return 0;}
{% endhighlight %}

{% highlight C line %}
#include<stdio.h>

int main(void) {
  printf("Hello World");
  return 0;
}
{% endhighlight %}

To humans they are vastly different. Linters are great tools because they help use enforce a common style in our programs. With a strict linter a program written by a team of developers will look more like a program written by a single developer. I usually set up my linter to adhere to the dominant community standard for the language I am working in. 

Static analyzers try to find potential bugs in the logic of our programs. Naturally when one is found we should not ignore it and we should not allow these issues to accumulate.

[Rubocop](https://github.com/bbatsov/rubocop) is a phenomenal linter/static analyzer for Ruby. Rubocop will not only enforces the ruby community style guides, but also detect long, complex methods or files and detect common problems in your code.

### Continuous Integration

It's important all strict checks are performed in CI so that it's not possible to accidentally introduce broken code. A CI build should pass only when

* The project builds
* The tests pass
* There are not style issues
* There are no static analysis issues
* All other project specific checks are ok

Even if errors are caught in CI the same checks should be simple for all developers to run on their machine. Ideally a rake/make task should be used both for CI and locally.  


### Conclusion

Failing CI on linter warnings and treating warnings as errors might sound ridiculous, but I have found it to be very valuable both for teams and individuals. When I started using Rubocop the restriction of 10 lines per method felt unrealistic, but without fault I have found that every time I hit that limit there is a clear way to refactor out part of the code into another method. Having strict checks in place has helped me write cleaner code both in projects with these checks, but also in projects without them. In the end this leaves me more time to focus on solving the problem at hand and I spend less time debugging. 
