Database Layout Proposal
========================
This is my proposal for the db layout.  Thoughts?

Company
========
* Ticker (string, unique)
* Name (string)
* Industry (string)
* Sector (string)

PricePoint (historical, current)
===========
* Company::Ticker (foregin key, has_one)
* Price (number)
* Datetime (datetime, utc?)

User
====
* name
* email
* password
* favorited stocks (foreighn key to Company::Ticker, has_many)

[NO]Tweet (current)
=====
* content (string)
* author (string) [MAYBE?]
* Company::Ticker (foreign key, has_one)

Indices
=======
* All instances of Company::Ticker
* PricePoint::Datetime

Results (current)
=================
* Company::Ticker (foreign key, has_one)
* score (-100 -> 100, floating point)
* tweet_text (text of tweet with similar score)
* tweet_author (author of tweet if available)
