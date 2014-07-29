http = require 'http'
logger = require '../libs/logger'
require '../libs/mockIndexStream'

class TrendingNews

    INDEX_STREAM: 'http://trendspottr.com/indexStream.php?q=' # instance variable

    TOPICS: [
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
    ] # instance variable


    results: {}

    constructor: (mode = '', @scoreThreshold = 100) ->
        if (mode == 'debug')
            logger.debugLevel = 'info'

        if (mode == 'test')
            logger.debugLevel = 'error'

        logger.log 'warn', 'in ' + mode + 'Mode'
        logger.log 'info', 'scoreThreshold = ' + @scoreThreshold

    filterNewsByTrendScore = (allNewsItems) ->
        # private, anonymous function

        classObj = this
        allNewsItems.filter (item) -> item.trending_score >= classObj.scoreThreshold

    getFilteredNewsForTopic = (topic, httpCallback) ->
        # private, anonymous function

        logger.log 'info', 'Getting all news for topic: ' + topic + '...'
        classObj = this

        http.get(classObj.INDEX_STREAM+topic, (response) ->
            data = ''

            response.on('data', (chunk) ->
                data += chunk
            )

            response.on('end', ->
                if (response.statusCode == 200)
                    allNewsItems = (JSON.parse(data)).link_list # strip topic name and status code
                    logger.log 'info', '# ' + topic + ' items before filter: ' + allNewsItems.length

                    filteredItems = filterNewsByTrendScore.call classObj, allNewsItems
                    logger.log 'info', '# ' + topic + ' items after filter: ' + filteredItems.length

                    httpCallback.call classObj,topic,filteredItems
                else
                    classObj.handleBadResponse topic, response.statusCode
            )

            response.on('error', (e) ->
                classObj.handleError topic, e.message, 'response'
            )
        ).on('error', (e) -> # on request error
            classObj.handleError topic, e.message, 'request'
        )

    resultsCallback = (topic, result) ->
        # private, anonymous callback to provide access to results

        classObj = this
        classObj.results[topic] = result

        if (Object.keys(classObj.results).length == classObj.TOPICS.length)
            classObj.handleResults classObj.results

    handleResults: (res) ->
        # method (public)

        logger.log 'warn', res

    handleBadResponse: (topic, statusCode) ->
        # method (public)

        logger.log 'error', 'Response with status code ' + statusCode + ' for topic ' + topic

    handleError: (topic, message, timeOfError) ->
        # method (public)

        logger.log 'error', 'Problem with ' + timeOfError + ' for topic ' + topic + ': ' + message

    getLatest: ->
        # method (public)

        logger.log 'info', 'Getting latest trending news items for ' + @TOPICS.length + ' topics...'
        getFilteredNewsForTopic.call(this, topic, resultsCallback) for topic in @TOPICS


#trendingNews = new TrendingNews 'debug', 80
#trendingNews.getLatest()

module.exports = TrendingNews
