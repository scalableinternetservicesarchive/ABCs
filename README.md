# Market Chirp

Market Chirp is a stock recommendation web application developed in the context of UCLA CS 188, [Scalable Internet Services](http://www.scalableinternetservices.com/) in Fall 2015 by the team ABCs. Market Chirp analyzes tweet sentiments concerning certain stocks and recommends if the stock is bearish or bullish.

Updates to the project can be found in the [Pivotal Tracker](https://www.pivotaltracker.com/n/projects/1446710).

<img src="https://travis-ci.org/scalableinternetservices/ABCs.svg?branch=master">

## Installation

1. Download the environment file [here](https://drive.google.com/file/d/0BxbbvzrBaj8rODBJYm42ajZaN1U) (requires access), rename it in the top level directory as `.env`.

2. Run `bundle install` to install dependencies. (It may be necessary to install Command Line Tools for XCode).

3. Make sure MySQL is running in the background with `mysqld &`.

4. Since the DB now contains unique columns, you cannot just re-seed the DB. You must drop the tables, re-create them, and then seed them.  The best way of doing this is running `rake db:reset`. You will lose any data that is not seeded!

5. Start the server by running `rails s`.

## Team - ABCs
| <img src="https://avatars1.githubusercontent.com/u/5299614?v=3&s=460" width="250"> | <img src="https://avatars1.githubusercontent.com/u/1539144?v=3&s=460" width="250"> | <img src="https://scontent-sjc2-1.xx.fbcdn.net/hphotos-xaf1/v/t1.0-9/12011295_569942286490494_4254956360489592239_n.jpg?oh=3a03380e7bc946dad17a3ac5cd5971e2&oe=56884624" width="250"> | <img src="https://scontent-sjc2-1.xx.fbcdn.net/hphotos-xpa1/v/t34.0-0/p206x206/12081590_10153357735913743_2130296283_n.jpg?oh=b058f27a41ef81fad25cb4712f851392&oe=5619AB53" width="250"> |
| -------------------------------------------- | ------------------------------------------------ | ---------------------------------------- | ----------------------------------------------- |
| [Brandon Woo](https://github.com/bmwwoo)     | [Chris Konstad](https://github.com/chriskonstad) | [Alex Fong](https://github.com/apfong)   | [Sakib Shaikh](https://github.com/Sakibs)   |
