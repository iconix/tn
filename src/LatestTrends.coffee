module.exports = TrendingNews

http = require 'http'
require '../libs/mockIndexStream'

logger = require '../libs/logger'

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

    constructor: (debugMode = false, score = 100) ->
        logger.debugLevel = if debugMode then 'info' else 'warn'
        scoreThreshold = score

        logger.log 'warn', 'debugMode is ' + debugMode
        logger.log 'info', 'scoreThreshold = ' + scoreThreshold

    filterNewsByTrendScore = (allNewsItems) ->
        allNewsItems.filter (item) -> item.trending_score >= scoreThreshold

    getFilteredNewsForTopic = (topic, httpCallback) ->
        logger.log 'info', 'Getting all news for topic: ' + topic + '...'

        http.get(indexStream+topic, (response) ->
            data = ''

            response.on('data', (chunk) ->
                data += chunk
            )

            response.on('end', ->
                allNewsItems = (JSON.parse(data)).link_list # strip topic name and status code
                logger.log 'info', '# ' + topic + ' items before filter: ' + allNewsItems.length

                filteredItems = filterNewsByTrendScore allNewsItems
                logger.log 'info', '# ' + topic + ' items after filter: ' + filteredItems.length

                httpCallback topic,filteredItems
            )

            response.on('error', (e) ->
                logger.log 'error', 'Problem with response for topic ' + topic + ': ' + e.message
            )
        ).on('error', (e) -> # on request error
            logger.log 'error', 'Problem with request for topic ' + topic + ': ' + e.message
        )

    resultsCallback = (topic, result) ->
        # callback to provide access to results

        results[topic] = result

        if (Object.keys(results).length == topics.length)
            logger.log 'warn', results

    getLatest: ->
        logger.log 'info', 'Getting latest trending news items for ' + topics.length + ' topics...'
        getFilteredNewsForTopic(topic, resultsCallback) for topic in topics


trendingNews = new TrendingNews true, 80
trendingNews.getLatest()
