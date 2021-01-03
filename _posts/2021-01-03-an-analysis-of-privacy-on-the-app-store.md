---
layout: post
title:  "An Analysis of Privacy on the App Store"
categories: privacy ios
date: 2021-01-03
description: >
  Which are the worst apps for privacy on the App Store? Do free apps collect more data than paid ones? In this post I analyse data from the App Store to answer these questions and more.
---

In iOS 14.3, Apple added their new [app privacy details](https://developer.apple.com/app-store/app-privacy-details/) to App Store listings. App privacy details, which are sometimes compared to the nutritional labels on foodstuff, are details about the data an app collects and the purposes and use of such data. What can we learn by analysing this data?

From the 14<sup>th</sup> of December 2020, all new apps and app updates have to provide information on the data the app collects. This is used to power the app privacy details labelling. On Twitter, videos scrolling through the privacy listing for Facebook circulated immediately after the 14.3 release.

This system is somewhat flawed, because app developers can, at least in theory, lie about the data they collect. Some apps that profess to collect no data, actually turn out to collect a bunch if you read their privacy policy. However, the punishment for being caught lying, removal from the App Store, is a strong deterrent and it's safe to assume most developers will have been truthful in their accounts.

An interesting side-effect of this, is that Apple has now made available the same data that can be found in terse and hard to parse privacy policies as simple and structured data that can be parsed and analysed. In this post I will do just that i.e. collect and analyse the privacy details for thousands of the most popular apps on the App Store.

## Collecting the Data

If you just want to read the juicy details feel free to skip to the [analysis](#analysis).

Apple makes the privacy labelling data available for each app on the App Store via an API used by the App Store apps. By reverse engineering the App Store apps I've figured out how to make the API divulge this data on a per app basis.

This only gets me the privacy data for a single app, but I want to analyse popular apps. A good source of popular apps are the charts the App Store provides on a per app category basis. An example of this is "Top Free" apps in "Education". These listings contain up to 200 apps per category and price point(i.e. free or paid).

On the UK store, which is the store I've used for all this analysis, there are 24 categories. Each of which have top charts with up to 200 paid and 200 free apps. This means the theoretical total number of apps is 9600. However, because some apps occupy chart positions in multiple categories and because the charts also contain app bundles the actual number is lower.

The full list of categories is:

| **Category**           |
|------------------------|
| Book                   |
| Business               |
| Developer Tools        |
| Education              |
| Entertainment          |
| Finance                |
| Food & Drink           |
| Graphics & Design      |
| Health & Fitness       |
| Lifestyle              |
| Magazines & Newspapers |
| Medical                |
| Music                  |
| Navigation             |
| News                   |
| Photo & Video          |
| Productivity           |
| Reference              |
| Shopping               |
| Social Networking      |
| Sports                 |
| Travel                 |
| Utilities              |
| Weather                |


## Structure of the Data

If you don't care about the exact details and structure of the data feel free to skip to the [analysis](#analysis).

The structure of the data returned by the App Store API is

{% highlight json %}
{
  "id": <number>,
  "type": "apps",
  "href": <href>,
  "attributes": {
    "privacyDetails": <privacy-details>
  }
}
{% endhighlight %}

The `<privacy-details>` section of this document is the important bit. It's an array where each item has the following structure.


{% highlight json %}
{
  "privacyType": <human-readable-description>,
  "identifier": <string-identifier>,
  "description": <human-readable-description>,
  "dataCategories": <data-categories>,
  "purposes": <data-purposes>
}

{% endhighlight %}

The `<string-identifier>` is one of

| **Identifier**         |
|------------------------|
| DATA_LINKED_TO_YOU     |
| DATA_NOT_COLLECTED     |
| DATA_NOT_LINKED_TO_YOU |
| DATA_USED_TO_TRACK_YOU |

`DATA_NOT_COLLECTED` is used as a marker in which case `dataCategories` and `purposes` are both empty and this is the only element in the `privacyDetails` array.

`DATA_USED_TO_TRACK_YOU` contains details on data used to track you across websites and apps owned by other companies, Apple's description is *The following data may be used to track you across apps and websites owned by other companies:*. For this entry `purposes` will be empty and `dataCategories` contain the different data types that are tracked across apps and websites owned by other companies.

`DATA_LINKED_TO_YOU` and `DATA_NOT_LINKED_TO_YOU` both contain data types with purposes specific granularity. This means that `dataCategories` will be empty and the different data types are in `purposes`. Apple's description for `DATA_LINKED_TO_YOU` and `DATA_NOT_LINKED_TO_YOU` are *The following data, which may be collected and linked to your identity, may be used for the following purposes:* and *The following data, which may be collected but is not linked to your identity, may be used for the following purposes:* respectively.

`<data-purposes>` is an array of purposes with the following structure:

{% highlight json %}
{
  "purpose": <human-readable-purpose>,
  "identifier": <purpose-identifier>,
  "dataCategories": <data-categories>,
}

{% endhighlight %}

The different values for `<purpose-identifier>` are:

| **Purpose**             |
|-------------------------|
| ANALYTICS               |
| APP_FUNCTIONALITY       |
| DEVELOPERS_ADVERTISING  |
| OTHER_PURPOSES          |
| PRODUCT_PERSONALIZATION |
| THIRD_PARTY_ADVERTISING |

These are described by Apple in their [documentation](https://developer.apple.com/app-store/app-privacy-details/#data-type-usage), but I've added them here for completeness.

| Purpose                              | Definition                                                                                                                                                                                                      |
|--------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Third-Party Advertising              | Such as displaying third-party ads in your app, or sharing data with entities who display third-party ads                                                                                                       |
| Developer’s Advertising or Marketing | Such as displaying first-party ads in your app, sending  marketing communications directly to your users, or sharing data with  entities who will display your ads                                              |
| Analytics                            | Using data to evaluate user behavior, including to  understand the effectiveness of existing product features, plan new  features, or measure audience size or characteristics                                  |
| Product Personalization              | Customizing what the user sees, such as a list of recommended products, posts, or suggestions                                                                                                                   |
| App Functionality                    | Such as to authenticate the user, enable features,  prevent fraud, implement security measures, ensure server up-time,  minimize app crashes, improve scalability and performance, or perform  customer support |
| Other Purposes                       | Any other purposes not listed                                                                                                                                                                                   |

Lastly `<data-categories>` is an array of objects with the following structure:

{% highlight json %}
{
  "dataCategory": <human-readable-purpose>,
  "identifier": <data-category-identifier>,
  "dataTypes": [<human-readable-data-type>],
}

{% endhighlight %}


The full list of data types and the categories they belong to is:


{% highlight json %}
{
  "IDENTIFIERS": [
    "User ID",
    "Device ID"
  ],
  "USAGE_DATA": [
    "Other Usage Data",
    "Advertising Data",
    "Product Interaction"
  ],
  "DIAGNOSTICS": [
    "Performance Data",
    "Other Diagnostic Data",
    "Crash Data"
  ],
  "CONTACT_INFO": [
    "Name",
    "Other User Contact Info",
    "Phone Number",
    "Email Address",
    "Physical Address"
  ],
  "PURCHASES": [
    "Purchase History"
  ],
  "LOCATION": [
    "Coarse Location",
    "Precise Location"
  ],
  "USER_CONTENT": [
    "Other User Content",
    "Photos or Videos",
    "Audio Data",
    "Emails or Text Messages",
    "Customer Support",
    "Gameplay Content"
  ],
  "CONTACTS": [
    "Contacts"
  ],
  "OTHER": [
    "Other Data Types"
  ],
  "BROWSING_HISTORY": [
    "Browsing History"
  ],
  "SEARCH_HISTORY": [
    "Search History"
  ],
  "HEALTH_AND_FITNESS": [
    "Health",
    "Fitness"
  ],
  "FINANCIAL_INFO": [
    "Credit Info",
    "Payment Info",
    "Other Financial Info"
  ],
  "SENSITIVE_INFO": [
    "Sensitive Info"
  ]
}

{% endhighlight %}


Let's do some analysis of this data

## Analysis

The data set I've collected contains 9082 combinations of apps and a position in a given category chart. In total there are 9040 unique apps in this data set.

Most charts contain 200 or nearly 200 apps, however **Graphics & Design(Paid)**, **Developer Tools(Paid)**, and **Magazines & Newspapers(Paid)** all have fewer than 90 apps so I'm dropping them from further analysis.

Because the privacy details have only been required for new apps and updates since mid December, not all apps contain information about privacy details. After removing those apps 3164 apps remain in the data set. Breaking this down by chart, several charts have less than 25 apps so I am dropping them from further analysis too. This leaves 3027 apps in the data set.

In total the following charts have been dropped:

* Education(Paid)
* Navigation(Paid)
* Sports(Paid)
* Business(Paid)
* Food & Drink(Paid)
* Shopping(Paid)
* Medical(Paid)
* Magazines & Newspapers(Paid)

For the analysis there are a few different data points that are interesting:

+ Apps that collect data this is linked to the user and how many such data types they collect.<sup>*</sup>
+ Apps that collect no data.
+ Third Party tracking, i.e. tracking users across apps and websites owned by other companies and the how many(max 32) such data types they collect.

\* Data that is linked to the user for the purpose of supporting app functionality, that is the `APP_FUNCTIONALITY` purpose, is legitimate and will be exclude from the following analysis. This leaves 160 data types spread across 5 purposes.

I am excluding data that is collected but not linked to the user, in part to keep down the length of the analysis and in part because it's the least interesting. I'll probably do a follow up post on it later.

The questions I'll be looking at for this analysis are:

1. [Do free apps collect more data?](#free-vs-paid)
1. [Which are the worst charts?](#worst-charts)
1. [Which apps in the whole data set are the worst?](#worst-apps)
1. [Which apps lie subtly about the nature of data they collect?](#oxymorons)

But first let's have a quick look at the data set.

*Note: The images in this post can be clicked to show larger versions*

[![Histogram plot of data types collected. The apps that collect zero such data types dominate]({{ 'img/app-privacy/data-collected-histogram-plot.svg' | asset_url }})](/img/app-privacy/data-collected-histogram-plot.svg)

As we can see here, most apps collect no data outside of that which supports the app's functionality. To get a better view of the apps that do collect data, let's remove the majority of apps that don't.

[![Histogram plot of data types collected with zero values removed.]({{ 'img/app-privacy/data-collected-histogram-non-zero-plot.svg' | asset_url }})](/img/app-privacy/data-collected-histogram-non-zero-plot.svg)

Still the amount of data collected is fairly low, but there's a curious set of outliers somewhere around 120 data types collected. All of those outliers have something in common, see if you can figure it out before I reveal the answer later in the post.

How about third party tracking?

[![Histogram plot of third party tracking data types collected. The apps that collect zero such data types dominate]({{ 'img/app-privacy/ttp-histogram-plot.svg' | asset_url }})](/img/app-privacy/ttp-histogram-plot.svg)

Again most apps don't collect any data types for third party tracking. Let's repeat the process from above by removing those that do no tracking.

[![Histogram plot of third party tracking data types collected with zero values removed.]({{ 'img/app-privacy/ttp-histogram-non-zero-plot.svg' | asset_url }})](/img/app-privacy/ttp-histogram-non-zero-plot.svg)


Now that we have an overview of the data let's move on to answer the questions posed above.

### Free vs Paid

A fairly common meme in the discourse around free apps is: "if you're not paying for the product, you are the product". Facebook is probably the quintessential example of this business model. Facebook makes money not from users paying them, but from advertisers paying to show hyper targeted ads to Facebook's users. So is there truth to the meme? Do free apps track more than paid ones? I asked my Twitter followers this [question](https://twitter.com/K0nserv/status/1344412528823173120), most people thought so.

As previously established we'll look at a few different data points to determine this. First of all, do free apps collect more data types that are linked to the user for non-app functionality purposes?


[![Box Plot comparing free vs paid apps. The median number of data points collect is 2 for paid apps and 8 for free apps]({{ 'img/app-privacy/free-vs-paid-box-plot.svg' | asset_url }})](/img/app-privacy/free-vs-paid-box-plot.svg)

Yes they certainly do. The median number of such data types for free apps is 8 and for paid apps it's 2. The mean is impacted by outliers in the free category and is ~12.1 for free apps and ~3.7 for paid apps.

If we look at the number of apps that don't collect data, as a percentage. It's also clear that paid apps are much less likely to collect data.

| **Type** | **Percentage** | **# Apps** | **# Apps that don't collect** |
|----------|------------------------------------------------|--------------------|----------------------------------|
| Free     | ~9.7%                                          | 2459               | 239                              |
| Paid     | ~55.8%                                         | 568                | 317                              |

Lastly do free apps collect more data types that are used to track the users across other apps and websites i.e. data categories with the identifier `DATA_USED_TO_TRACK_YOU`?

[![Box Plot comparing free vs paid apps. The median number of data types collect is 1 for paid apps and 3 for free apps]({{ 'img/app-privacy/free-vs-paid-tracking-box-plot.svg' | asset_url }})](/img/app-privacy/free-vs-paid-tracking-box-plot.svg)

Yes they do, the median number of data types used to track users across other apps and websites is 1 for free apps and 0 for paid apps. The mean is ~2.0 for free apps, but only ~0.2 for paid apps.

For all three metrics considered, it turns out that my Twitter followers were correct. Free apps do collect more data than paid ones.

### Worst Charts

Of the 40 remaining charts in the data set which are the worst? Let's again start by considering the number of data types collected and linked to the user for non-app functionality purposes.

[![Box Plot with the top 5 worst charts measured by their median: "Shopping(Free)", "Travel(Free)", "Sports(Free)", "Business(Free)", and "Health & Fitness(Free)"]({{ 'img/app-privacy/worsts-charts-box-plot.svg' | asset_url }})](/img/app-privacy/worsts-charts-box-plot.svg)

| **Chart**              | **Mean**  | **Median** |
|------------------------|-----------|------------|
| Shopping(Free)         | 11.938931 | 8.0        |
| Travel(Free)           | 10.486486 | 6.0        |
| Sports(Free)           | 9.410000  | 5.5        |
| Business(Free)         | 11.558559 | 5.0        |
| Health & Fitness(Free) | 10.013245 | 5.0        |

Here *Shopping(Free)* is the clear winner, perhaps because of amount of analytics used to improve and understand things like checkout conversion and cart abandonment.

Another interesting observation here is that worst 23 charts, sorted be median, are all free. The first paid chart is *Travel(Paid)* at position 24.


When considering the percentage of apps in each chart that don't collect any data there's commonality with the above. *Health & Fitness(Free)*, *Shopping(Free)*, and *Travel(Free)* all show up again.

| **Chart**              | **Percentage** | **#Apps** | **#Apps that don’t collect** |
|------------------------|----------------|-----------|------------------------------|
| Health & Fitness(Free) |            ~2% |       151 |                            3 |
|       News(Free)       |          ~2.8% |       108 |                            3 |
|     Shopping(Free)     |          ~3.1% |       131 |                            4 |
|      Travel(Free)      |           ~3.6 |       111 |                            4 |
|   Photo & Video(Free)  |          ~3.7% |       136 |                            5 |

The same divide between paid and free apps occur again here. The first paid app shows up only at position 23(*Weather(Paid)* at ~27.8%).

When considering tracking across other apps and websites this is the result:

[![Box Plot with the top 5 worst measured by their median data types collected for third party tracking: "News(Free)", "Entertainment(Free)", "Sports(Free)", "Shopping(Free)", and "Health & Fitness(Free)"]({{ 'img/app-privacy/worsts-charts-tpt-box-plot.svg' | asset_url }})](/img/app-privacy/worsts-charts-tpt-box-plot.svg)

| **Chart**              | **Mean** | **Median** |
|------------------------|----------|------------|
| News(Free)             | 2.731481 | 3          |
| Shopping(Free)         | 3.488550 | 2          |
| Sports(Free)           | 3.020000 | 2          |
| Entertainment(Free)    | 2.390000 | 2          |
| Health & Fitness(Free) | 2.125828 | 2          |

The trend with paid vs free apps repeats again, the first paid chart is *News(Paid)* at position 25. In fact by this measure all free charts track more than paid ones, although a fair number of free charts have a median of 0 too.

### Worst Apps

Let's now focus on individual apps, which are the absolute worst apps? While I was fetching the data, I tweeted some [preliminary results](https://twitter.com/K0nserv/status/1344051828602916877) based on a shallow analysis of response size. By this metric, all of Facebook's apps were extremely data hungry. Let's see if that conclusion holds up to more rigorous analysis.

Let's start by again considering data collected and linked to the user for non-app functionality purposes. Here are the top 20 apps by this measure.

| **App**                        | **#Data Types Collected** |
|--------------------------------|--------------------------|
| Instagram                      | 128                    |
| Creator Studio from Facebook   | 128                    |
| Portal from Facebook           | 128                    |
| Boomerang from Instagram       | 128                    |
| Threads from Instagram         | 128                    |
| Layout from Instagram          | 128                    |
| Facebook                       | 128                    |
| Facebook Gaming                | 128                    |
| Facebook Business Suite        | 128                    |
| Oculus                         | 128                    |
| Facebook Adverts Manager       | 128                    |
| Messenger                      | 128                    |
| LinkedIn: Job Search & News    | 91                     |
| Klarna \| Shop now. Pay later. | 56                     |
| Football Index - Bet & Trade   | 56                     |
| The Telegraph News             | 55                     |
| Ovia Pregnancy Tracker         | 54                     |
| Ovia Parenting & Baby Tracker  | 54                     |
| Ovia Fertility & Cycle Tracker | 54                     |
| Nectar: Shop & Collect Points  | 53                     |

Can you spot the pattern? The top 12 apps are all from the same company, Facebook. All of Facebook's apps collect an ungodly amount of data, the nearest other app is LinkedIn which collects 37 fewer data types. Keep in mind that the maximum number of data types an app can collect and link to the user outside of app functionality is 160(32 data types, across 5 purposes), Facebook manages to get almost all the way there at 128. All of Facebook's apps declare the same set of data types collected. It's easier to look at the data Facebook **does not collect** than the data they do collect.

**Data types not collected by Facebook:**

| **Purpose**             | **Category**       | **Data Type**           |
|-------------------------|--------------------|-------------------------|
| ANALYTICS               | FINANCIAL_INFO     | Credit Info             |
| ANALYTICS               | USER_CONTENT       | Emails or Text Messages |
| DEVELOPERS_ADVERTISING  | FINANCIAL_INFO     | Credit Info             |
| DEVELOPERS_ADVERTISING  | FINANCIAL_INFO     | Payment Info            |
| DEVELOPERS_ADVERTISING  | HEALTH_AND_FITNESS | Fitness                 |
| DEVELOPERS_ADVERTISING  | HEALTH_AND_FITNESS | Health                  |
| DEVELOPERS_ADVERTISING  | SENSITIVE_INFO     | Sensitive Info          |
| DEVELOPERS_ADVERTISING  | USER_CONTENT       | Audio Data              |
| DEVELOPERS_ADVERTISING  | USER_CONTENT       | Customer Support        |
| DEVELOPERS_ADVERTISING  | USER_CONTENT       | Emails or Text Messages |
| OTHER_PURPOSES          | FINANCIAL_INFO     | Credit Info             |
| OTHER_PURPOSES          | FINANCIAL_INFO     | Payment Info            |
| OTHER_PURPOSES          | HEALTH_AND_FITNESS | Fitness                 |
| OTHER_PURPOSES          | HEALTH_AND_FITNESS | Health                  |
| OTHER_PURPOSES          | SENSITIVE_INFO     | Sensitive Info          |
| OTHER_PURPOSES          | USER_CONTENT       | Audio Data              |
| OTHER_PURPOSES          | USER_CONTENT       | Emails or Text Messages |
| PRODUCT_PERSONALIZATION | FINANCIAL_INFO     | Credit Info             |
| PRODUCT_PERSONALIZATION | FINANCIAL_INFO     | Payment Info            |
| PRODUCT_PERSONALIZATION | HEALTH_AND_FITNESS | Fitness                 |
| PRODUCT_PERSONALIZATION | HEALTH_AND_FITNESS | Health                  |
| PRODUCT_PERSONALIZATION | USER_CONTENT       | Audio Data              |
| PRODUCT_PERSONALIZATION | USER_CONTENT       | Customer Support        |
| PRODUCT_PERSONALIZATION | USER_CONTENT       | Emails or Text Messages |
| THIRD_PARTY_ADVERTISING | FINANCIAL_INFO     | Credit Info             |
| THIRD_PARTY_ADVERTISING | FINANCIAL_INFO     | Payment Info            |
| THIRD_PARTY_ADVERTISING | HEALTH_AND_FITNESS | Fitness                 |
| THIRD_PARTY_ADVERTISING | HEALTH_AND_FITNESS | Health                  |
| THIRD_PARTY_ADVERTISING | SENSITIVE_INFO     | Sensitive Info          |
| THIRD_PARTY_ADVERTISING | USER_CONTENT       | Audio Data              |
| THIRD_PARTY_ADVERTISING | USER_CONTENT       | Customer Support        |
| THIRD_PARTY_ADVERTISING | USER_CONTENT       | Emails or Text Messages |

Data types shows up several times here, but remember we care about the combination of data type and purpose.

The complete set of data they collect and link to users for non-app functionality purposes is scarier. [Yikes](https://gist.github.com/k0nserv/8198a365f776c3a2c41a0e0cd259c1f5).

This is how the data breaks down for Facebook's apps:

| **Purpose/Category**                    | **#Data Types** |
|-----------------------------------------|-----------------|
| Used to Track(3rd Party)                 | 7               |
| Linked To You(Analytics)                | 30.0            |
| Linked To You(Developer Advertising)    | 24.0            |
| Linked To You(Other Purposes)           | 25.0            |
| Linked To Your(Product Personalisation) | 25.0            |
| Linked To You(Third Party Advertising)  | 24.0            |


What about apps that track you across apps and websites used by other companies?


| **App**                          | **#Data Types Tracked** |
|----------------------------------|-------------------------|
| M&S - Fashion, Food & Homeware   | 19.0                    |
| The Telegraph News               | 17.0                    |
| Yelp: Local Food & Services      | 17.0                    |
| Football Index - Bet & Trade     | 17.0                    |
| Depop - Buy and sell fashion     | 15.0                    |
| EliteSingles: Dating for 30+     | 15.0                    |
| Monese: A Banking Alternative    | 14.0                    |
| 墨迹天气-MojiWeather             | 14.0                    |
| Investing.com Stocks & Finance   | 14.0                    |
| BetBull: Sport \| Tips \| Casino | 14.0                    |
| IMVU: 3D Avatar Creator & Chat   | 13.0                    |
| Nectar: Shop & Collect Points    | 13.0                    |
| Yandex Go — taxi and delivery    | 13.0                    |
| Gaia GPS Hiking, Biking Maps     | 13.0                    |
| MamaBeing Fit                    | 13.0                    |
| The Sole Womens                  | 13.0                    |
| Yandex.Navigator – Parking       | 13.0                    |
| Candide – Plants & Gardening     | 13.0                    |
| TOPPS® KICK® Card Trader         | 13.0                    |
| AP News                          | 12.0                    |

Here Facebook's apps aren't showing up, after all they are the people who facilitate the tracking across apps and websites. Unsurprisingly, all of the above apps are free. The first paid app in this list is Badoo Premium at position 147.



### Oxymorons

Astute readers will have noticed that some of the data types are linked to the user by their very nature and as such the combination of the data category *Data Not Linked to You* and these data types are an oxymoron.

For example your phone number, email address, name, or physical address are always linked to you even if the data isn't attached to an identifier. Further, as numerous news outlets — including [The New York Times](https://www.nytimes.com/interactive/2019/12/19/opinion/location-tracking-cell-phone.html) — have reported, precise location can be re-identified with fair ease, by identifying locations such as homes and offices. Recovering a user's identity from the contents of their text messages and emails is also trivial.

Let's look at apps that collect one of the above data types for the category *Data Not Linked to You*.

In this data set there are 434 apps that collect such oxymoron data types. The worst two offenders, by count, are *myCricket App* and *FootballNet QPR* although neither collect precise location which is reassuring. *The Weather Network*, *OpenSnow*, *Yanosik*, *imo video calls and chat*, and *MyRadar Weather Radar* are examples of apps that collect precise locations for third party advertising purposes. In fact *imo video calls and chat*, and *MyRadar Weather Radar* collect precise location for every single one of the six different purposes.

*Taimi: LGBTQ+ Dating, Chat* is an LGBTQ+ dating app that collects precise location for analytics purposes. This is of particular note because in many countries LGBTQ+ people face significant risk if their status is exposed.


## Conclusion

We've learned that a fairly large amount of apps collect none or very little data that is linked to the user for non-app functionality purposes. However there are extreme outliers, not the least of which is Facebook.

Free apps collect significantly more data than paid ones and anyone who cares about their privacy should opt to pay for the apps they use.

The data at this stage is sparse, because only about 1/3 of the apps in the data set have added privacy details. In the future this will reach close to 100% and I will redo this analysis.

If you have other questions about the data that you'd like me to cover please DM me on [Twitter](https://twitter.com/K0nserv) and I'll try to add them to this post, or if there are a lot of questions I'll do a follow up post.

