# Surlicious

A monitoring tool for online services which require 100% uptime.

> Don't trust the uptimes of your online services! - anonymous

## How does it work?

Surlicious monitors a service from the outside by exposing an API endpoint that can be POST'ed at. If Surlicious does not register such a POST, called a **heartbeat**, it sends alert mails to the email address of the account so actions can be taken to solve the issue.

## How can I try it?

Visit [Surlicious](surlicious.exomie.eu), register with your email address, verify your email address and you are ready to go.

## Bugs

Albeit, the project is feature complete in its base form there are some rough edges, especially in the UI/UX department. Also there is no guarantee for the absence of bugs, so if you find bugs, please open an issue and we can sort it out.

## Contribution

Every help is more than welcome on the project. We use [The D Style](https://dlang.org/dstyle.html) as a coding guideline. 

## Missing parts of the README

If you expect something to find in this document but it isn't there, open an issue and I'll add the section. :)