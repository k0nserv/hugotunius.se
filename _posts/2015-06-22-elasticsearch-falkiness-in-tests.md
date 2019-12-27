---
layout: post
title:  "Elasticsearch Flakiness in Tests"
categories: rails elasticsearch
date: 2015-06-22
redirect_from:
  - /rails/api/caching/2015/01/21/active-model-serializer-caching.html
  - /rails/elasticsearch/2015/06/22/elasticsearch-falkiness-in-tests.html
---

[Elasticsearch](https://www.elastic.co/products/elasticsearch) is an awesome tool for building fast and powerful search experiences. However integration testing with Elasticsearch can be painful. Elasticsearch uses a HTTP REST API to modify, setup, and search indices. The nature of this API is eventually consistent, creating an index will not be done when the HTTP call returns. This eventual consistency can become painful in test since creating, indexing, searching and then removing the index needs to happen in rapid succession.

When this happens test will start failing for seemingly unexplainable reasons at random times. The errors will look like this:

{% highlight text line %}
Elasticsearch::Transport::Transport::Errors::ServiceUnavailable at /users

[503] {"error":"SearchPhaseExecutionException[Failed to execute phase [query], all shards failed]","status":503}
{% endhighlight %}

A poor solution to this problem is adding a sleep after asking elasticsearch to create your indices, as an example.

{% highlight ruby line %}
create_list(:user, 10)
User.import
sleep 1 # Might work, Might not work. Depending on Java GC and other factors
{% endhighlight %}

This [post](https://www.devmynd.com/blog/2014-2-dealing-with-failing-elasticserach-tests) by [DevMynd](https://www.devmynd.com) suggests wrapping search calls in retry logic which will work, but with the unfortunate side effect of having to modify the application code itself.

The solution I've found to work is using the `refresh_index!` method after creating indices in tests. This will trigger the refresh action on the index as described [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-refresh.html).

**From the docs:**

> The refresh API allows to explicitly refresh one or more index, making all operations performed since the last refresh available for search. The (near) real-time capabilities depend on the index engine used. For example, the internal one requires refresh to be called, but by default a refresh is scheduled periodically.

Putting it all together a test for a users endpoint might have the following `before` and `after` actions

{% highlight ruby line %}
RSpec.describe '/users' do
  before(:each) do
    User.__elasticsearch__.create_index! force: true, index: User.index_name
    create_list(:user, 10)
    User.import
    User.__elasticsearch__.refresh_index!
  end

  after(:each) do
    User.__elasticsearch__.indices.delete index: User.index_name
  end

  # Tests...
end
{% endhighlight %}

In rare cases it seems like not even this will solve the problem, although so far it has for us. As suggested in this [issue](https://github.com/elastic/elasticsearch-ruby/issues/181#issuecomment-112781924) on GitHub watching the cluster health and waiting until it becomes green is another option.

This has been a great annoyance when encountered and I hope this post will help you avoid the same annoyance.
