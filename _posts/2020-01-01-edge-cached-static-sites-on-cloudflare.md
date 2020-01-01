---
layout: post
title: "Edge Cached Static Sites on CloudFlare"
categories: web
date: 2020-01-01
description: >
  Blazing fast static websites via edge caching courtesy of CloudFlare.
---

This website, for the most part, is still set up in the way I outlined in [The One Cent Blog](https://hugotunius.se/2016/01/10/the-one-cent-blog.html), but I've made a few recent improvements. Previously only static assets were edge cached via CloudFlare while the HTML pages themselves were not. With these recent changes the HTML pages themselves benefit from CloudFlare's edge caching. With this change [TTFB(Time To First Byte)](https://en.wikipedia.org/wiki/Time_to_first_byte) was reduced by almost 90%.

TTFB is a critical performance metric. To give you an idea of
how much it matters, on this site, regardless of TTFB, the time it takes to download the content is around ~1-3ms. Without edge caching the TTFB used to be around ~300ms from Europe because the origin server is in us-east-1, with edge caching it's ~30ms.

Edge Caching isn't as easy as a switch of a button unfortunately. CloudFlare will not revalidate pages unless told explicitly to do so or because the cache expired. For a low traffic site it's beneficial to use a high TTL for CloudFlare's edge cache but when changes are made they should still be reflected immediately, fortunately it's possible to tell CloudFlare to purge the edge cached pages on deploy, this is what I have done.

The details that I'll describe here are Jekyll and Ruby specific, but they apply equally to any static site generator generated website.

CloudFlare does not edge cache HTML files by default, this needs to be adjusted with a custom [page rule](https://www.cloudflare.com/features-page-rules/). CloudFlare's free plan includes three page rules.

![]({{ 'img/cloudflare-static-edge-cache/page-rules.png' | asset_url }})

_Page rules for edge caching_

Here are the relevant rules I've used:

* **Browser Cache TTL:** 30 minutes, the lowest setting
* **Cache Level:** Cache Everything
* **Edge Cache TTL:** 6 days

However this is no good. If you change anything about your site those changes will not be visible to your readers for 6 days. When you fix those embarrassing spelling errors in your blog post while it's trending on Hacker News you want the fix out immediately, not in six days. You need to tell CloudFlare to purge the cache, luckily CloudFlare has an API for that.


{% highlight ruby %}

def required_env_variable(name)
  required_env_variables([name])[0]
end

def required_env_variables(names)
  any_missing = names.any? { |name| ENV[name].nil? || ENV[name].empty? }
  if any_missing
    names = names.map { |name| "`#{name}`" }.join(', ')
    message = "The #{names} environment variable(s) are required"
    raise message

  end

  names.map { |name| ENV[name] }
end

def cloudflare_purge_cache_url(zone_id)
  "https://api.cloudflare.com/client/v4/zones/#{zone_id}/purge_cache"
end

task :purge_cloudflare_html_files do
  # Find all HTML files in the generated site
  html_files = Dir.glob('**/*.html', base: '_site')
  urls =  html_files.map do |file|
    "https://hugotunius.se/#{file}"
  end
  urls.push "https://hugotunius.se"

  zone_id = required_env_variable('CF_ZONE_ID')
  uri = URI(
    cloudflare_purge_cache_url(zone_id)
  )

  # Cloudflare's API only handles 30 entries at the time
  urls.each_slice(30) do |slice|
    payload =  {
        files: slice
    }
    (api_key, api_email) = required_env_variables(
      ['CF_API_KEY', 'CF_API_EMAIL']
    )
    headers = {
      'Authorization': "Bearer #{api_key}",
      'X-Auth-Email': api_email,
      'Content-Type': 'application/json',
    }

    response = Net::HTTP.post uri, payload.to_json, headers

    success = Net::HTTPResponse::CODE_TO_OBJ[response.code] != Net::HTTPOK

    raise "Failed to purge cloudflare cache" unless success
  end
end
{% endhighlight %}

This is the rake task I've used to clear CloudFlare's edge cache after each new release of this site. It's fairly straightforward: Find all HTML files produced, construct their URLs, and instruct CloudFlare to purge them via the CloudFlare API.

The required environment variables are:

`CF_ZONE_ID` The zone id of your CloudFlare site. This is **not** the id in the URL on the dashboard, it's different for some reason. I found the correct id by looking at the XHR requests in the network tab when navigating around in the dashboard.

`CF_API_KEY` The API token to use, this can be generated under your profile when logged in to CloudFlare.

`CF_API_EMAIL` The same email address you use to log in to CloudFlare.

All of these variables are sensitive and should be treated with care. On Travis CI I have encrypted them just as I have with the site's S3 credentials.

These are the [relevant commits](https://github.com/k0nserv/hugotunius.se/compare/573ad3df64dd91ad2ce134bc5d869add03cdc636...81cb539ad07f484ee73f90858f78482832d68b6f) to implement this for this site.
