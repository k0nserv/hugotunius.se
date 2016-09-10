---
layout: post
title: "Fixing Storyboards without Apple"
categories: ios segue view-controller swift
date: 2016-09-10
description: >
  Fixing weak interfaces in storyboards and segues
  without Apple's help.

---

A [blog post](https://www.dzombak.com/blog/2016/09/Fixing-Storyboard-Segues--Only-Apple-Can-Do-This.html) in this week's [iOS Weekly](https://iosdevweekly.com/issues/267) jogged my memory on one of my least favourite things about iOS development; segues and parameters. As [Chris](https://twitter.com/cdzombak) points out in the post Storyboard segues are broken, specifically they are broken because you can't inject dependencies and parameters in the view controllers involved in segues in a good way. This is something I've always been annoyed by and I've often taken to not using storyboards at all preferring to use XIBs instead.

The core of the problem is as a developer you lose control over the object creation for your view controllers. You can't enforce the required parameters via a constructor, because you can't provide a constructor at all. Instead you have to resort to using `var` for everything in your view controllers even values that are required as. Since the values can't be set during the constructor they also have to be optionals of some kind. Here's an example:

{% highlight swift %}
class UserDetailsViewController: UIViewController {
  var userID: Int! // or Int?
  var userRepository: UserRepository! // or UserRepository?
  var delegate: UserDetailsViewControllerDelegate?
}
{% endhighlight %}

From this interface it might be clear that `userID` and `userRepository` are required while `delegate` is truly an optional, it also might not be. The interface simply isn't strict enough to give us any clues. Swift gives us developers a strong type system that helps us express the intent of our code without resorting to comments or convention however in this case we are forced by the segue system to forgo the power of the type system. This code could be improved slightly by including comments:

{% highlight swift %}
class UserDetailsViewController: UIViewController {
  // The id of the user whose details to show
  // required
  var userID: Int! // or Int?

  // A user repository to be used for fetching the user date
  // required
  var userRepository: UserRepository! // or UserRepository?

  // An optional delegate
  var delegate: UserDetailsViewControllerDelegate?
}
{% endhighlight %}

At the end of the post Chris asserts the following, which I agree with:

> "But fundamentally, this is something only Apple can fix."

While true that Apple is the only entity that can come up with a first class solution to this problem there are ways to work around it. Chris mentions a new library by Thoughtbot that tries to make segues safer and easier to use called [Perform](https://github.com/thoughtbot/Perform).

I've previously had to solve this problem too. I've used two different methods. Like I mentioned above I've often opted to only use XIBs which opens up the option of just using a regular old constructor. When segues(and storyboards) have been pre existing or a requirement I've adopted a different pattern using a second object.

## Using XIBs

When using XIBs you can create your own constructors that call `init(nibName nibName: String?, bundle nibBundle: NSBundle?)` instead of relying on the OS the unpack your interface and initializing your controller.

{% highlight swift %}
class UserDetailsViewController: UIViewController {
  private let userID: Int
  private let userRepository: UserRepository
  var delegate: UserDetailsViewControllerDelegate?

  init(userId: Int, userRepository: UserRepository) {
    super.init(nibName: "UserDetailsViewController", bundle: nil)
    self.userID = userID
    self.userRepository = userRepository
  }
}
{% endhighlight %}

With this approach you can encode in the interface of your controller what you expect the caller to initialize your controller with. You can also mark the values as private. There's no need for the comments anymore either and it's impossible for the caller to initialize this class without also providing the required values.

Now you might argue that this is a bit of a copout because it's not using storyboards at all, seems a bit weird for a post about fixing storyboards. I'd urge you not to underestimated the power of the humble XIB, with them you can accomplish much of what you can do in a storyboard and while there are some limitations compared to storyboards there are also some upsides as seen above.


## Using a configuration object

This method uses a secondary configuration object and expose only that object in the view controller's public interface. This is a bit cumbersome since it requires adding a second object, but it does work well with segues. Continuing with the same example I'd write it like this.

{% highlight swift %}
struct UserDetailsViewControllerConfiguration {
  private let userID: Int
  private let userRepository: UserRepository
}

class UserDetailsViewController: UIViewController {
  private let userID: Int!
  private let userRepository: UserRepository!

  var delegate: UserDetailsViewControllerDelegate?

  // This value should be set before the view controller is present
  // not setting the value likely results in a crash.
  var configuration: UserDetailsViewControllerConfiguration? {
    set {
      self.userId = newValue.userID
      self.userRepository = newValue.userRepository
    }
  }
}
{% endhighlight %}

The values still need to be optionals of some kind and the caller can still skip the setting the `configuration` value all together. However the required parameters and dependencies are nicely encapsulated in the constructor of the configuration object. Again it's not possible to construct an invalid configuration object and the code is still self documenting.
