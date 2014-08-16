http = require 'http'
storage = require 'node-persist'

logger = require '../lib/logger'
hashCode = require '../lib/hashCode'
#require '../lib/mockIndexStream'

class TrendingNews

    INDEX_STREAM: 'http://trendspottr.com/indexStream.php?q=' # prototype prop

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
    ] # prototype prop

    @STORAGE_DIR: 'TNStorage' # class prop

    scoreThreshold = 100 # private var

    constructor: (mode = 'default', score = 100) ->
        if (!mode)
            mode = 'default'

        if (!score)
            score = 100

        if (mode == 'debug')
            logger.debugLevel = 'info'
        else if (mode == 'test')
            logger.debugLevel = 'error'
        else
            mode = 'default'

        logger.log 'warn', 'in ' + mode + 'Mode'

        scoreThreshold = score
        logger.log 'warn', 'scoreThreshold = ' + scoreThreshold

        @results = {}

    filterNewsByTrendScore = (allNewsItems) ->
        # private, anonymous function

        classObj = this
        allNewsItems.filter (item) -> item.trending_score >= scoreThreshold

    filterNewsIfSeenBefore = (newsItems) ->
        # private, anonymous function that determines if a news item has ever been seen before
        # by looking at its title

        classObj = this
        unseen = []

        storage.initSync({
            dir: TrendingNews.STORAGE_DIR
        })

        for item in newsItems
            titleHash = hashCode.hash item.title
            seenWhen = storage.getItem(titleHash)
            logger.log 'info', storage.length() + ' ' + titleHash + ' ' + seenWhen

            if (seenWhen == undefined)
                unseen.push item
                seenWhen = [ new Date(Date.now()) ]
            else
                seenWhen.push new Date(Date.now())

            storage.setItem(titleHash, seenWhen)

        return unseen

    getFilteredNewsForTopic = (topic, successCallback) ->
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

                    unseenItems = filterNewsIfSeenBefore.call classObj, filteredItems
                    logger.log 'info', '# ' + topic + ' items never seen before: ' + unseenItems.length

                    logger.log 'info', '---'

                    successCallback.call classObj,topic, unseenItems
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

        logger.log 'error', 'Problem with ' + timeOfError + ' for topic ' + topic + '... ' + message

    getLatest: ->
        # method (public)

        logger.log 'info', 'Getting latest trending news items for ' + @TOPICS.length + ' topic(s)...'
        getFilteredNewsForTopic.call(this, topic, resultsCallback) for topic in @TOPICS


module.exports = TrendingNews
