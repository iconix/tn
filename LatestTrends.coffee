http = require 'http'
require './mockIndexStream'

class TrendingNews

    indexStream = 'http://trendspottr.com/indexStream.php?q='

    topics = [
        'News'
        'Technology'
        'Content Marketing'
        'Infographics'
        'Economy'
        'Sports'
        'Pop Culture'
        'Politics'
        'Science'
        'Celebrity'
    ]

    scoreThreshold = 0

    results = {}

    constructor: (score = 100) ->
        scoreThreshold = score

    filterNewsByTrendScore = (allNewsItems) ->
        allNewsItems.filter (item) -> item.trending_score >= scoreThreshold

    getFilteredNewsForTopic = (topic, httpCallback) ->
        http.get(indexStream+topic, (response) ->
            data = ''

            response.on('data', (chunk) ->
                data += chunk
            )

            response.on('end', ->
                allNewsItems = (JSON.parse(data)).link_list # strip topic name and status code
                filteredItems = filterNewsByTrendScore allNewsItems
                httpCallback topic,filteredItems
            )
        )

    resultsCallback = (topic, result) ->
        # callback to provide access to results

        results[topic] = result

        if (Object.keys(results).length == topics.length)
            console.log results

    getLatestNews: ->
        getFilteredNewsForTopic(topic, resultsCallback) for topic in topics


trendingNews = new TrendingNews 80
trendingNews.getLatestNews()
