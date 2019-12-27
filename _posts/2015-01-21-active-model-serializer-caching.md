---
layout: post
title:  "ActiveModel Serializers and Caching"
categories: rails api caching
date: 2015-01-21
---

We have recently started using [ActiveModel::Serializer](https://github.com/rails-api/active_model_serializers) at [FishBrain](http://fishbrain.com) in favour of jbuilder. During this ongoing switch we have had to deal with a few issues mainly regarding to caching. If you haven't used ActiveModel::Serializer before I would recommend you check it out.

There is plenty of documentation for AMS in general, but less so for caching.
This post is based on version 0.8.0 which is currently the recommended version.

## View Caching

While AMS is quite a bit faster than jbuilder it is still painfuly slow without caching the resulting json in a few scenarios. Luckily caching is extremely simple. In its simplest form this is all it takes

{% highlight ruby line %}
class PostSerializer < ActiveModel::Serializer
  # Specify that we want to cache the results
  cached

  # Delegate the cache key to the object
  delegate :cache_key, to: :object

  attributes :title, :body

  has_many :comments

  url :post
end
{% endhighlight %}

It's also possible to define a more specialized cache key by implementing `cache_key` manually instead.

This caching will work well and give you a huge win in speed. The invalidation is also handled nicely due to the `updated_at` property of ActiveRecord's default cache_key implementation.

Here is an example

> post/1-20150121205945000000000

Notice that the `updated_at` value is part of the cache key. A simple `Post.find(1).touch` will invalidate the cache and prevent staleness of the view.

There is however a big issue here. When the model changes we are fine thanks to `updated_at`, but what about when the Serializer changes?

This is how AMS calculates the cache_key in 0.8.0

{% highlight ruby line %}
# I have altered it slightly to reduce line length
# https://github.com/rails-api/active_model_serializers/blob/0-8-stable/lib/active_model/serializer.rb#L357
components = [self.class.to_s.underscore, cache_key, 'serializable-hash']
cache.fetch expand_cache_key(components)
{% endhighlight %}

As seen here the actual serializer is not part of the cache key. This will cause any changes made to serializer to not appear before the cache is invalidated either manually or over time as the `updated_at` fields of the models change. ActionView solves this by calculating a Digest for each view. The digest will change when ever the view or any of it's dependencies change. I will show a simpler approach to solving this problem.

### Versioning the view

The general idea is to keep a version number for each serializer, this is quite prone to human error, but with a defined step during code reviews it should be caught. To facilitate this we will create a base serializer with this functionallity.

{% highlight ruby line %}
class BaseSerializer < ActiveModel::Serializer
  # The version of the serializer. Should be incremented
  # if the serializer is changed in a way that causes
  # the output to change
  class_attribute :version
  # The version starts at 1
  self.version = 1

  # Notice that this is a class method and is not overriding
  # the instance method from ActiveModel::Serializer
  def self.cache_key
    ['version', self.version]
  end
end
{% endhighlight %}

With this change the new `PostSerializer` will look like this

{% highlight ruby line %}
class PostSerializer < BaseSerializer
  # Specify that we want to cache the results
  cached
  self.version = 1

  attributes :title, :body

  has_many :comments

  url :post

  # Instead of delegating the cache_key to the object
  # we now override it and include the serializer's
  # cache key too
  def cache_key
    self.class.cache_key << object.cache_key
  end
end
{% endhighlight %}

The new cache key will look like this

> version/1/post/1-20150121205945000000000

and after AMS applies their extra key components like this:

> post_serializer/version/1/post/1-20150121205945000000000

If we now wish to change the serializer by adding a new attribute or changing something we just have to bump the version to `2` when we are done and the cache will invalidate.

## Bonus: ETags

I've implemented roughly the same thing in our API, but I was also looking into ETagging and HTTP based caching overall. This suffers from the same issue as the view caching.

{% highlight ruby line %}
# If the view changes, but the models stay the same
# The ETag will remain the same
if stale? etag: @post, last_modified: @post.updated_at
  render json: @post
end
{% endhighlight %}

We can reuse the versioning of the serializers to prevent cache staleness due to change in the serializer too.

Instead of using `etag: @post` we will build an etag based on both the model and the view.

{% highlight ruby line %}
components = [PostSerializer.cache_key, @post]
if stale? etag: components, last_modified: @post.updated_at
  render json: @post
end
{% endhighlight %}

We leave the `last_modified` set to `@post.updated_at` because as long as the Etag changes the request will be considered to be stale by rails.

**Warning:** If the client only uses `If-Modified-Since` and skips `If-None-Match` this can still cause staleness of the view. To combat this the version of the Serializer could be changed to a unixtimestamp and the maximum of the version and the model's `updated_at` could be for the `last_modified` value.

## Removing the human error

The worst part of this approach is that it requires humans to remember the version bump when changing anything. From experience we know that humans aren't very good at such tasks. I have not come up with a suitable solution for calculating a digest based on the actual code in the Serializer in an efficent way, but this would be preferable. If you think you have a good solution I'd love to hear it.

[Nathan Kontny](https://twitter.com/natekontny) has also published a solution to this problem.




