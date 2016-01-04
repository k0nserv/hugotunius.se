---
layout: post
title:  "Stop over validating your forms"
categories: ux security culture web
date: 2016-01-04
---

Validation errors suck! They cause your users frustration, they hurt conversion rates, and when they are incorrect they are confusing. My email address `h@tunius.se` gets rejected as being invalid quite frequently and it's always just as frustrating. Validation errors should be actual objective errors in the submitted data, not arbitrary subjective over validation. 

## Email

Email addresses may be the the most over validated field out there. 

If you search for

> validate email address 

on Stackoverflow, [this](https://stackoverflow.com/questions/46155/validate-email-address-in-javascript) is the top rated question and the accepted answer is wrong! 

Email regex validations stretch from the completely broken `[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}` to the examples in the above question. The full regex for email address valid under RFC822 can be found [here](http://www.ex-parrot.com/pdw/Mail-RFC822-Address.html). I don't know of anyone actually using the full regex and I would argue that there is no need for it. 

The purpose of validating an email address is supposedly to catch user error. The most probable user error is making a spelling mistake and a spelling mistake is not something you will catch with a regex in any case. My recommendation for email validation is therefore to validate that the user has entered at least one character, an at sign, and at least one more character. With this validation the invalid email address `a@+` would be considered valid, but that is a trade off I am perfectly willing to make if it means no users are locked out because the developer googled email regex and implemented the first result. When you have the email address send the user a  confirmation email. That is after all the ultimate way to validate an email address.

Everyone knows not to parse XML with regexes by now. It's time we stop validating email addresses with them too. 

David Celis' [blog post](http://davidcel.is/posts/stop-validating-email-addresses-with-regex/) on the topic is a good read. 

## Passwords

Another commonly over validated field is the password field. A lot of the validations for passwords originate in the good intention of forcing the user to pick a strong password. As [Joel Califa](http://twitter.com/notdetails) so beautifully points out in his blog post [Patronizing Passwords](http://joelcalifa.com/blog/patronizing-passwords/) there are much better ways to achieve this goal. Some of it originate in horrible bad practice such as storing passwords in plain text or trying to protect against SQL injections by forbidding certain characters. 

There is one category of over validating passwords that is especially bad and that is the maximum length. If you have a password field with a maximum length less than 200 characters in one of your websites stop reading now and go change it. The max limit for passwords should be put in place strictly to prevent potential DOS attacks based on hashing very long passwords. 

A minimum length is one of the few validations that are actually beneficial. Passwords should be at least 8 characters but preferably much higher than that. Most users will still try to remember all their passwords in their head so a strict limit higher than 8 is probably going to hurt conversion rates. Taking a note out of Joel's book hinting that the password is weaker when it is very short is a good idea.   

## Names

Names are not validated per se, but very often name is split into two with first name and last name being separate values. This [post](http://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/) by [Patrick McKenzie](http://www.kalzumeus.com/about/) is the best piece of writing on the topic of names I've ever come across. It describes and dismisses many commonly held believes about names.

Names should be a single field. It should be up to the user to choose how they want to be addressed.

