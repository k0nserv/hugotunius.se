---
layout: post
title: "How to hack half of all websites"
categories: javascript security magecart
date: 2018-11-29
description: >
  How to hack half of all the websites on the internet and most of the top websites in the world.
---

What if there was a reliable method to hack half of the websites on the internet in a single attack? Imagine if you could compromise a single entity and gain immediate Javascript code execution on half the websites in the world; including **google.com**, **stackoverflow.com**, **reddit.com** and 93% of the Alexa top 10k. You could exfiltrate all kinds of valuable data such as passwords, email addresses, and full credit card details including [CCVs](https://en.wikipedia.org/wiki/Card_security_code).

If you have been paying attention at all to the goings on in information security this year you will have heard of the Magecart hacker group. Magecart successfully hacked several high profile targets and stole the personal information and credit card details of hundreds of thousands of people.

In June 2018 we learned that thousands of Ticketmaster UK customers had their data compromised if they purchased or attempted to purchase tickets between February and 23rd of June 2018. One of those people was me buying tickets for [Lowlands 2018](https://lowlands.nl/) which was a blast, not getting hacked, but the festival. This turned out to be an attack by the Magecart actor. [RiskIQ](https://www.riskiq.com/) has a great [write up](https://www.riskiq.com/blog/labs/magecart-ticketmaster-breach/) of the details of how this attack was performed. The TL;DR is: Magecart compromised a script on the Ticketmaster payment page and appended some additional Javascript to it that would siphon PII and credit card details as they were entered. In the case of Ticketmaster a script from a third party, [Ibenta](https://www.inbenta.com/en/), was compromised.

Later that year, in September, [it came to light](https://www.riskiq.com/blog/labs/magecart-british-airways-breach/) that British Airways had also fallen victim to Magecart and some 380,000 customer's details were stolen with the same method. In this case a first party Javascript was highjacked and modified to siphon data. Not long after this is Newegg was [discovered to be the next victim](https://www.riskiq.com/blog/labs/magecart-newegg/) of Magecart. The Magecart actors also compromised hundreds of other websites via other third parties.

If you are Magecart you have now proven how effective this particular method could be, but you are ambitious. You would like to go after bigger fish and compromise even more payment processes. Who would be a good next target? How about an entity that can run arbitrary Javascript on [55.6% of the world websites](https://w3techs.com/technologies/details/ta-googleanalytics/all/all) and [93.63% of the Alexa top ten thousand](https://trends.builtwith.com/analytics/Google-Analytics)? If so your answer is **Google Analytics**.

Just stop and think about the number of payment and checkout flows in the world that will have Google Analytics loaded on them. After all the whole point of Google Analytics is gaining insight in user behaviour and a crucial part of that is establishing CLTV, customer lifetime value, which Google Analytics can of course help with. Personally I think this prospect is absolutely terrifying.

Google is one of the richest and most powerful companies in the world and as such is a very difficult target to successfully attack. However they have certainly been hacked previously and even the most hardened security processes aren't foolproof. Nothing is impossible to hack.

## To summarise

1. Hack Google Analytics. _Left as an exercise to the reader._
1. Inject PII and credit card siphoning code in their delivery scripts. _Maybe steal the some code from Magecart, just remember to change the collection server._
1. ???
1. Profit
