---
title: "A more in depth look into Elasticsearch"
date: 2019-09-28
tags: [Elasticsearch, Java, Work]
---

All the information I got for this article was obtained from the [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/client/java-rest/current/java-rest-high.html). This will be a basic overview of building a query, using nested models, and aggregations.

I recently wrote a post about all the work I did to speed up searching, and I wanted to go a little bit more in depth as to what I learned. Some of the stuff that I was doing was pretty trivial, but others like aggregation, was not. I'll start with the basics.

## Building Queries

On our home page we have a search bar with a few basic options. Such as the ability to choose a category or choose what fields to do a keyword search on. For example, if I wanted to search for a specific title but not search for that keyword in the description, I would only select title. This led to me using basic term queries to gain the most amount of information, which I could then filter based on users needs.

```java
public SearchResult search(searchOptions){
    // The top level request
    SearchRequest searchRequest = new SearchRequest();
    // The source AKA the queries
    SearchSourceBuilder searchSourceBuilder = new SearchSourceBuilder();
    // A bool query, does basic yes or no
    BoolQueryBuilder bqb = QueryBuilders.BoolQuery();
    for(field : searchOptions.fieldsToSearch){
        sourceBuilder.should(QueryBuilders.termQuery(field, searchOptions.query));
    }
    // Add the bool query to the source
    searchSourceBuilder.query(bqb);
    // Add the source to the search request
    searchRequest.source(searchSourceBuilder);
    // Send the request to elasticsearch
    SearchResponse searchResponse =
        client.search(searchRequest, RequestOptions.DEFAULT);
    return searchResponse;
}
```

The above code allowed me to create a search that searched for the query in each field that the user requested. The bool query allows you to add multiple sub queries to a search request. There are 5 different ways to add a sub query to the bool query. They are must, mustNot, should, shouldNot, and filter. The must and mustNot clauses mean AND. This means if I have two must clauses, a document (the object that you put into elasticsearch) needs to satisfy both of those conditions in order to be returned. The should clauses act as an OR. This means it will return anything with any of those clauses. The filter clauses acts exactly like the must clauses, except that they do not contribute to scoring. Scoring is just a way to measure how well a document fits the query.

If I were to make a bool query looked like this:

|Clauses|Term|Query|
|---|---|---|
|Must|Title|"Elasticsearch"|
|Must|Description|"Elasticsearch"|

And our documents were to look like:

```json
{
    "title":"A cool book on elasticsearch",
    "description": "This is a cool book on all things elasticsearch"
},
{
    "title":"This is a cool book",
    "description": "This is a cool book but not on elasticsearch"
}
```

The first document would come back but not the second. This is because the second does not have "elasticsearch" in the title. Now if we did the same this, but with using the should clauses:

|Clauses|Term|Query|
|---|---|---|
|Should|Title|"Elasticsearch"|
|Should|Description|"Elasticsearch"|

And if we used the same documents as above, we would be both of them back. But, this time we could use the scores to figure out which one was a better fit for our query. The first document would score higher because it matches more of our should clauses. We know that every document will match at least one should clause, but the more they match, the higher score they are given.

Now there are many other ways to build queries, this was just the way that fit our needs the best. A List of all the other query types is on the elasticsearch documentation under [Building Queries](https://www.elastic.co/guide/en/elasticsearch/client/java-rest/current/java-rest-high-query-builders.html).

One thing that really helped me figure out how to write my queries was to make a couple dummy documents, put them in elasticsearch and build json queries. You can then hit elasticsearch using cURL, giving you a quick turn-around time. Once you have your query, you translate it into the language of your choice.

## Nested models

Nested models are useful for when you have documents containing an array of things that cannot be mixed together when searching. Take the following document for example:

```json
{
    "title": "Cool New Book",
    "chapters":[
        {
            "chapterTitle": "Chapter 1: Java",
            "description": "Java programming"
        },
        {
            "chapterTitle": "Chapter 1: Python",
            "description": "Best Python programming"
        },
        {
            "chapterTitle": "Chapter 1: C++",
            "description": "Low level programming"
        }
    ]
}
```

Now if we were to build a query for the chapters field using the fields and queries:

|Clauses|Term|Query|
|---|---|---|
|Should|chapters.chapterTitle|"Java"|
|Should|chapters.description|"Low"|

We would surprisingly get that document as a result. How odd! But, the way that elasticsearch handles arrays turns the document into something that looks like this:

```json
{
    "title": "Cool New Book",
    "chapters.chapterTitle": [
        "Chapter 1: Java",
        "Chapter 1: Python",
        "Chapter 1: C++"
    ],
    "chapters.description": [
        "Java programming",
        "Best Python programming",
        "Low level programming"
    ]
}
```

Now in order to make sure that our query only matches documents with a chapter that has a chapterTitle that contains "Java" and a description that contains "Low" we need to use nested models. This makes elasticsearch search through arrays as expected. So what we do is add a mapping for the document.

```java
public MappingResponse updateMapping(){
    // Create or replace a mapping in the index "Books"
    PutMappingRequest request = new PutMappingRequest("Books");
    // Create the actual mapping
    request.source(
    "{\n" +
    "  \"properties\": {\n" +
    "    \"chapters\": {\n" +
    "      \"type\": \"nested\"\n" +
    "    }\n" +
    "  }\n" +
    "}",
    XContentType.JSON);
    // Send the mapping to elasticsearch, this must be done
    // while the index is empty or it will fail
    AcknowledgedResponse putMappingResponse =
        client.indices().putMapping(request, RequestOptions.DEFAULT);
    return putMappingResponse;
}
```

We can then add all of our documents back to the index and use our new mapping. This gives us the advantage of being able to search specific objects in arrays.

## Aggregations

Aggregations are a way for elasticsearch tell you stats about the documents that matched the query you sent to it. For this example we are going to pretend to make a e-commerce site. We will have products that are in elasticsearch and we want to display some statistics on those products. Say we want to tell the customer how many of the products that matched their query are produced in a certain region. Assume the following documents are in our index:

```json
{
    "product": "Laptop",
    "cost": 800.00,
    "madeIn": "China"
},
{
    "product": "Desk",
    "cost": 200.00,
    "madeIn": "USA"
},
{
    "product": "Bed",
    "cost": 1000.00,
    "madeIn": "USA"
}
```

If our customer were to do a blank search and get all three of these items back, we would want to tell them that there are two items made in "USA" and one item made in "China". Now we could make our server do that, but it is slow and costly. Besides, let elasticsearch do what it does best. We would want a term aggregation on the "madeIn" field. The term aggregation gives us the number of separate terms from a certain field. Here is how we would do this in Java.

```java
public TermsAggregationBuilder buildAggregations(){
    TermsAggregationBuilder termsAggregationBuilder = AggregationBuilders
        // This is the name for the aggregation,
        //so it can be separated from other term aggregations
        .terms("madeIn_aggregation")
        // This is the field it is using,
        // in our case we could also use "product" or "cost"
        .field("madeIn");
    return termsAggregationBuilder;
}
```

Hopefully this post has shone some light onto the cool features of elasticsearch.
