---
layout: post
title:  "The one cent blog"
categories: aws cloudflare web ruby jekyll
redirect_from:
  - /aws/cloudflare/web/2016/01/10/the-one-cent-blog.md-the-one-cent-blog.html
  - /aws/cloudflare/web/2016/01/10/the-one-cent-blog.html
---

This post details how I run this website for about $0.01/month with great scaling and HTTPS using [S3][aws_s3], [Jekyll][jekyll], [Cloudflare][cloudflare] and [Travis-CI][travis_ci]. It should be noted that the cost varies depending on how much traffic your site sees, $0.01/month is just what I typically see on this website.

This post outlines how this site is setup and how you can created your own. Variables that will be different for each site are written as `<variable_name>`, everything should be replace including `<` and `>` for example `<author_name>` is replaced by `Hugo Tunius` for my site.

If you have any questions feel free to ask me about it on [Twitter](https://twitter.com/k0nserv).

## Domain

Any website needs a domain. If you don't have one you'll have to register one, this will also cost you some money(around $10/year is what I pay). Register a domain with a domain registrar, for example [Namecheap][namecheap]. It's not important which registrar you use as long as they support changing the name servers for your domain.

## Github

This blog is hosted on [Github][github_hugotunius_se] for free because it's open source. I've created a template blog based on this one which can be forked and modified to create your own. It's available [here](https://github.com/k0nserv/one-cent-blog/tree/S3). The template features some basic CSS and [AMP](https://www.ampproject.org) support. I am by no means a CSS genius, but the provided template is responsive, lightweight and clean. After forking the template there are some steps to set up Jekyll.

* Run `bundle install`.
* Copy the `_config.yml.sample` file to `_config.yml` and open it in your favourite text editor.
* Fill in the variables `name_of_site`, `timezone`, `url`, and `author_name`.
* At this point you should be able to use use `bundle exec rake watch` to start Jekyll.
* Navigate to http://localhost:4000 to see your site.
* At this point you can also make any modifications to the CSS and layout if you wish.

![]({{ 'img/one-cent-blog/jekyll-running.png' | asset_url }})

The next step is getting your site up on S3

## S3

[S3][aws_s3] is a file storage solution by [AWS(Amazon Web Services)](https://aws.amazon.com/). It's the only part of this setup that actually incurs any cost. This is were the one cent per month comes from.

**Note:** AWS S3 is charged based on usage so it could cost you more than one cent per month. I recommend setting up a billing alert somewhere around $5

+ Make a AWS root account at [https://aws.amazon.com](https://aws.amazon.com/) or sign in if you already have one.
+ Turn on [2FA](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa.html) for your root account.
+ Setup a [billing alert](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-what-is.html) at $5.
+ Go to `Services -> S3` and create a bucket named after your domain, in my case it's called `hugotunius.se`.
+ Under Properties click static website hosting and tick Enable website hosting.
+ Create a new IAM user(`Identify & Access Management -> Users -> Create New User`) named after your domain, in my case it's called `hugotunius.se`. Download and save the credentials for this user.
+ Attach a policy to the new user based on this template.

{% highlight text line %}
{
    "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::<bucket_name>",
                "arn:aws:s3:::<bucket_name>/*"
            ]
        }
    ]
}
{% endhighlight %}
+ Under the bucket properties in the permissions section click `Edit bucket policy` and add the following

{% highlight text line %}
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "PublicReadForGetBucketObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::<buck_name>/*"
        }
    ]
}
{% endhighlight %}

## Travis-CI

Travis CI is used to deploy the site to S3 every time a new commit is pushed to master. With open source repositories on Github Travis-CI is free. Setting up travis is simple

+ Sign in using your Github account.
+ Go to [Account](https://travis-ci.org/profile/) and click `Sync account`.
+ Find the repository for your website and switch it on.

![]({{ 'img/one-cent-blog/travis-ci-repo-list.png' | asset_url }})

+ Install the [Travis CLI Client](https://github.com/travis-ci/travis.rb) and login.
+ Run `$ travis encrypt S3_ACCESS_ID=<value_from_downloaded_s3_credentials> --add env.global`.
+ Run `$ travis encrypt S3_ACCESS_SECRET=<value_from_downloaded_s3_credentials> --add env.global`.
+ Update `s3_website.yml` with the real bucket name instead of `<BUCKET_NAME>`.
+ At this point committing and pushing will deploy the site to your s3 bucket.
+ It will be accessible at `http://<bucket_name>.s3-website-<aws-region>.amazonaws.com/`. Mine is at `hugotunius.se.s3-website-us-east-1.amazonaws.com`.

It's possible to deploy directly from the command line using:

{% highlight bash line %}
$ S3_ACCESS_ID=<value_from_downloaded_s3_credentials> S3_ACCESS_SECRET=<value_from_downloaded_s3_credentials> bundle exec rake deploy
{% endhighlight %}

Remember to put a space infront of the command to prevent the secret values ending up in your history.

## Cloudflare

Cloudflare is a company that provides a set of service based around caching, DDOS protection, DNS, and security. I use them primarily for caching, security, and DNS. Two things they offer that are very valuable is free HTTPs and having traffic to the root of your domain be served from your s3 bucket(this removes the need for a www subdomain). Before using Cloudflare I had a digitalocean droplet under the A record for `hugotunius.se` that simply redirect HTTP traffic to `www.hugotunius.se` which was a CNAME for my s3 bucket. With Cloudflare's feature [CNAME Flattening](https://blog.cloudflare.com/introducing-cname-flattening-rfc-compliant-cnames-at-a-domains-root/) Cloudflare can handle traffic to the root domain as a CNAME of the s3 bucket.

Simply signup to Cloudflare and follow their great on boarding tutorial and configure your DNS settings to use CNAME Flattening for your root record pointing it to your s3 bucket.


![]({{ 'img/one-cent-blog/cloudflare-dns.png' | asset_url }})


Under `Crypto` set SSL to `Flexible` and enable HTTP Strict Transport Security.

To force traffic to be HTTP setup a page rule for `http://<domain>/*` in Cloudflare under `Page Rules`
![]({{ 'img/one-cent-blog/force-https.png' | asset_url }})

## Additions

This sections contains some features that can be added to the site.

#### Google Analytics

Adding Google Analytics is as simply as adding the small script tag they provide to `_includes/head.html`.

#### Comments

Since all the content is static and there is no database comments are best provided by a third party for example [Disqus][disqus].

[aws_s3]: https://aws.amazon.com/s3/
[jekyll]: https://jekyllrb.com
[cloudflare]: https://www.cloudflare.com
[travis_ci]: https://travis-ci.org/
[disqus]: https://disqus.com
[namecheap]: https://namecheap.com
[github_hugotunius_se]: https://github.com/k0nserv/hugotunius.se

