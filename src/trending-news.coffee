http = require 'http'
storage = require 'node-persist'

logger = require '../lib/logger'
hashCode = require '../lib/hash-code'
config = require '../lib/config'
require '../lib/mock-index-stream'

###*
  * @classdesc Gets up-to-date, trending news
  *
  * @param [runMode='default'] {string} determines logging level and whether to use Nock
  * @param [scoreThreshold=100] {number} lowest allowed trending score for any news item
  *
  * @example How to create an instance, method(1)
  *   new TrendingNews(runMode, scoreThreshold)
  *
  * @example How to create an instance, method(2)
  *   new TrendingNews(runMode)
  *
  * @example How to create an instance, method(3)
  *   new TrendingNews(scoreThreshold)
  *
  * @property {object} results - latest news results [readonly]
  * @property {boolean} finished - if class instance is done processing
  *
  * @class TrendingNews
###
class TrendingNews

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  # scoreThreshold, results, finished are private shared among all instances of class
  # (http://book.mixu.net/node/ch6.html)

  # readonly
  scoreThreshold = 100 # private var
  get scoreThreshold: -> scoreThreshold

  # readonly
  results = null
  get results: -> results

  finished = false
  get finished: -> finished
  set finished: (value) -> finished = value

  ###*
    * @description Constructs a new framework for getting news
    * @constructs TrendingNews
  ###
  constructor: (mode = 'default', score = 100) ->
    if (!mode)
      mode = 'default'

    if (!score)
      score = 100

    # TODO make this a switch statement?
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

    logger.log 'warn', 'in ' + mode +
      'Mode (lowest log level: '+ logger.debugLevel + ')'

    scoreThreshold = score
    logger.log 'warn', 'scoreThreshold = ' + scoreThreshold

  ###*
    * @description Removes news items that fall below the trending score threshold
    *
    * @param newsItems {Array<Object>} list of news items to filter
    * @return {Array<Object>} list of news items, filtered by trending score
    *
    * @method filterNewsByTrendScore
    * @memberof TrendingNews
    * @instance
    * @private
  ###
  filterNewsByTrendScore = (newsItems) ->
    newsItems.filter (item) -> item.trending_score >= scoreThreshold

  ###*
    * @description Removes news items that have been seen before, determined by a hash of its title
    *
    * @param newsItems {Array<Object>} list of news items to filter
    * @return {Array<Object>} list of news items, filtered by seen before status
    *
    * @method filterNewsIfSeenBefore
    * @memberof TrendingNews
    * @instance
    * @private
  ###
  filterNewsIfSeenBefore = (newsItems) ->
    unseen = []

    storage.initSync({
      dir: config.STORAGE_DIR
    })

    for item in newsItems
      titleHash = hashCode.hash item.title
      logger.log 'info', titleHash + ', ' + item.title
      seenWhen = storage.getItem(titleHash)

      if (seenWhen == undefined)
        unseen.push item
        seenWhen = [ new Date(Date.now()) ]
      else
        try
          seenWhen.push new Date(Date.now())
        catch TypeError
          logger.log 'warn', 'Problem persisting storage for item ' +
            titleHash + ' in a previous cycle - marking as seen'
          seenWhen = [ new Date(Date.now()) ]

      storage.setItem(titleHash, seenWhen)

    return unseen

  ###*
    * @description Makes get call to an API for news about a topic
    *
    * @param topic {String} topic to get news about
    * @param resultsCallback {Function} function to call on the success of request
    *
    * @method getLatestNewsForTopic
    * @memberof TrendingNews
    * @instance
    * @private
  ###
  getLatestNewsForTopic = (topic, resultsCallback) ->
    logger.log 'info', 'Getting all news for topic: ' + topic + '...'
    # TODO set classObj var just once as instance var in constructor instead?
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
          logger.log 'info', '# ' + topic +
            ' items before filter: ' + allNewsItems.length

          # TODO dispatchStorageTask - store all response data asynchronously

          filteredItems = filterNewsByTrendScore allNewsItems
          logger.log 'info', '# ' + topic +
            ' items after filter: ' + filteredItems.length

          unseenItems = filterNewsIfSeenBefore filteredItems
          logger.log 'info', '# ' + topic +
            ' items never seen before: ' + unseenItems.length

          logger.log 'info', '---'

          resultsCallback.call classObj, topic, unseenItems
        else
          classObj.handleBadResponse.call classObj, topic, response.statusCode
      )

      response.on('error', (e) ->
        classObj.handleError.call classObj, topic, e.message, 'response'
      )
    ).on('error', (e) -> # on request error
      classObj.handleError.call classObj, topic, e.message, 'request'
    )

  ###*
    * @description Stores the resulting news items of a topic.
    * Waits for the results for all topics before handling
    *
    * @param topic {String} topic to get news about
    * @param result {Array<Object>}
    *
    * @callback TrendingNews~resultsCallback
    * @memberof TrendingNews
    * @instance
    * @private
  ###
  resultsCallback = (topic, result) ->
    classObj = this
    results[topic] = result

    if (Object.keys(results).length == config.TOPICS.length)
      classObj.logResults results
      finished = true

  ###*
    * @description Logs results of processing
    * Logs with level 'warn', public to allow for unit testing, although marked 'private'
    *
    * @param res {Object} results to log
    *
    * @method logResults
    * @memberof TrendingNews
    * @instance
    * @private
  ###
  logResults: (res) ->
    logger.log 'warn', res

  ###*
    * @description Logs errors that occur due to a 'bad' response status code.
    * Public to allow for unit testing, although marked 'private'
    *
    * @param topic {String} topic with bad response status code
    * @param statusCode {Number} bad response status code
    *
    * @method handleBadResponse
    * @memberof TrendingNews
    * @instance
    * @private
  ###
  handleBadResponse: (topic, statusCode) ->
    classObj = this

    logger.log 'error', 'Response with status code ' + statusCode +
      ' for topic ' + topic
    resultsCallback.call classObj, topic, []

  ###*
    * @description Logs errors that occur due to a bad request or response.
    * Public to allow for unit testing, although marked 'private'
    *
    * @param topic {String} topic being processed during error
    * @param message {String} error message
    * @param httpObjType {String} request or response, depending on when error occurred
    *
    * @method handleError
    * @memberof TrendingNews
    * @instance
    * @private
  ###
  handleError: (topic, message, httpObjType) ->
    classObj = this

    logger.log 'error', 'Problem with ' + httpObjType +
      ' for topic ' + topic + '... ' + message
    resultsCallback.call classObj, topic, []

  ###*
    * @description Processes every news topic in an asynchronous manner
    *
    * @method getLatest
    * @memberof TrendingNews
    * @instance
  ###
  getLatest: ->
    results = {}

    logger.log 'info', 'Getting latest trending news items for ' +
      config.TOPICS.length + ' topic(s)...'

    for topic in config.TOPICS
      getLatestNewsForTopic.call(this, topic, resultsCallback)

###*
  * A module for the {@link TrendingNews} class
  * @module trending-news
  *
  * @requires logger
  * @requires hash-code
  * @requires config
  * @requires mock-index-stream
###
module.exports = TrendingNews
