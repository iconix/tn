http = require 'http'
storage = require 'node-persist'

logger = require '../lib/logger'
hashCode = require '../lib/hash-code'
config = require '../lib/config'
require '../lib/mock-index-stream'

class TrendingNews

    scoreThreshold = 100 # private var
    results = null # private var
    finished = false # private var

    # prototype method
    getResults: () ->
        return results

    # prototype method
    isFinished: () ->
        return finished

    constructor: (mode = 'default', score = 100) ->
        if (!mode)
            mode = 'default'

        if (!score)
            score = 100

        if (mode == 'debug')
            logger.debugLevel = 'info'
        else if (mode == 'test')
            logger.debugLevel = 'error'
        else if (mode == 'prod')
            logger.debugLevel = 'info'
        else
            mode = 'default'

        if (mode == 'prod')
            process.env.NOCK_OFF = true
            logger.log 'warn', 'Nock is OFF!'
        else
            logger.log 'warn', 'Nock is ON'

        logger.log 'warn', 'in ' + mode + 'Mode (lowest log level: ' + logger.debugLevel + ')'

        scoreThreshold = score
        logger.log 'warn', 'scoreThreshold = ' + scoreThreshold

    filterNewsByTrendScore = (allNewsItems) ->
        # private, anonymous function

        allNewsItems.filter (item) -> item.trending_score >= scoreThreshold

    filterNewsIfSeenBefore = (newsItems) ->
        # private, anonymous function that determines if a news item has ever been seen before
        # by looking at its title

        unseen = []

        storage.initSync({
            dir: config.STORAGE_DIR
        })

        for item in newsItems
            titleHash = hashCode.hash item.title
            logger.log 'info', titleHash, item.title
            seenWhen = storage.getItem(titleHash)

            if (seenWhen == undefined)
                unseen.push item
                seenWhen = [ new Date(Date.now()) ]
            else
                try
                    seenWhen.push new Date(Date.now())
                catch TypeError
                    logger.log 'warn', 'Problem persisting storage for item ' + titleHash + ' in a previous cycle - marking as seen'
                    seenWhen = [ new Date(Date.now()) ]

            storage.setItem(titleHash, seenWhen)

        return unseen

    getLatestNewsForTopic = (topic, successCallback) ->
        # private, anonymous function

        logger.log 'info', 'Getting all news for topic: ' + topic + '...'
        classObj = this

        options = {
            hostname: config.REQUEST_HOSTNAME
            path: config.REQUEST_PATH + encodeURIComponent(topic)
            headers: config.REQUEST_HEADERS
        }

        http.get(options, (response) ->
            data = ''

            response.on('data', (chunk) ->
                data += chunk
            )

            response.on('end', ->
                if (response.statusCode == 200)
                    try
                        data = JSON.parse(data)
                    catch SyntaxError
                        logger.log 'error', "Response '" + data + "' is not valid JSON!"
                        data = {link_list: []}

                    allNewsItems = data.link_list # strip topic name and status code
                    logger.log 'info', '# ' + topic + ' items before filter: ' + allNewsItems.length

                    filteredItems = filterNewsByTrendScore allNewsItems
                    logger.log 'info', '# ' + topic + ' items after filter: ' + filteredItems.length

                    unseenItems = filterNewsIfSeenBefore filteredItems
                    logger.log 'info', '# ' + topic + ' items never seen before: ' + unseenItems.length

                    logger.log 'info', '---'

                    successCallback.call classObj, topic, unseenItems
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
        results[topic] = result

        if (Object.keys(results).length == config.TOPICS.length)
            classObj.handleResults results
            finished = true

    handleResults: (res) ->
        # method (public)

        logger.log 'warn', res

    handleBadResponse: (topic, statusCode) ->
        # method (public)
        
        logger.log 'error', 'Response with status code ' + statusCode + ' for topic ' + topic

    handleError: (topic, message, timeOfError) ->
        # method (public)

        logger.log 'error', 'Problem with ' + timeOfError + ' for topic ' + topic + '... ' + message

    getLatest: ->
        # method (public)

        results = {}

        logger.log 'info', 'Getting latest trending news items for ' + config.TOPICS.length + ' topic(s)...'
        getLatestNewsForTopic.call(this, topic, resultsCallback) for topic in config.TOPICS


module.exports = TrendingNews
