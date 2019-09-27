---
title: "How I sped up searching by 800%"
date: 2019-09-13
description: "Things I learned while updating an elasticsearch integration."
tags: [Elasticsearch, Java, Work]
---

Recently I was able to work on the Elasticsearch integration on the project I am currently on at work. The application is a catalog of [small satellite](https://en.wikipedia.org/wiki/Small_satellite) parts. It is a site where people who are building these small satellites can come explore the many different companies who are manufacturing these parts. It is a very interesting project to work on, sometimes it can be quite frustrating as well as rewarding.

Currently the searching on the site is pretty slow, we are talking 10+ seconds. I was tasked with fixing this problem on the new version of our front and search page (done in Vue.js). This led to me figuring out that our server was doing a log of number crunching in order to get stats on the returned parts. I also discovered that any filters we applied on the search was used to directly query our database, not even leveraging Elasticsearch.

My job was to create an endpoint on our server to accept search parameters an turn those into an elasticsearch query, and return the result as fast as the server would allow. While attempting to do this I discovered that elasticsearch is extremely fast at doing the searching, we are talking like 80ms. I knew in order to speed up our search I would have to use elasticsearch as much as possible.

This led to the usage of many different [queries](https://www.elastic.co/guide/en/elasticsearch/reference/7.2/query-dsl.html), such as:

- Match (given a field and string to use for the search)
- Match Phrase (given a field and string to use for the search)
- BoolQuery (shoulds, and musts, and filters)

Once I had updated the queries to match what the updated frontend was sending back, it was time to change how the statistics were calculated. What we needed was the list of all of the organizations from the returned parts list as well as how many of each there were. This was to let the user be able to filter their search and get more refined results. This led to me finding out about [aggregation](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html).

Using aggregations, I would be able to leverage elasticsearch to do the things our server used to do. Using the elasticsearch aggregations turned out to be much faster than the server. On this iteration of the search I was using the filter aggregation. There are many interesting other aggregations but they did not currently fit my need.

Once I had updated both the querying and the stats calculations I was getting back results in 1-1.5 seconds. This was a huge improvement and it was incredibly satisfying feeling.
