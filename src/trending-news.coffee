http = require 'http'
storage = require 'node-persist'

logger = require '../lib/logger'
hashCode = require '../lib/hash-code'
config = require '../lib/config'
require '../lib/mock-index-stream'

###
Class for getting up-to-date, trending news

@example How to create class instance, method 1
  new TrendingNews(runMode, scoreThreshold)

@example How to create class instance, method 2
  new TrendingNews(runMode)

@example How to create class instance, method 3
  new TrendingNews(scoreThreshold)
###
class TrendingNews

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  scoreThreshold = 100 # private var

  results = null
  # @property {Object} latest news results
  get results: -> results

  finished = false
  # @property {Boolean} if instance is done processing
  get finished: -> finished

  ###
  Constructs a new framework for getting news

  @overload TrendingNews(mode, score)
    @note Mode should equal 'debug', 'default', 'test', or 'prod'
    @note Score should be from 1 to 100 (inclusive)
    @param mode {String} determines logging level and whether to use Nock
    @param score {Number} lowest allowed trending score for any news item

  @overload TrendingNews(mode)
    @note Mode should equal 'debug', 'default', 'test', or 'prod'
    @note Score will default to 100
    @param mode {String} determines logging level and whether to use Nock

  @overload TrendingNews(score)
    @note Score should be from 1 to 100 (inclusive)
    @note Mode will default to 'default'
    @param score {Number} lowest allowed trending score for any news item
  ###
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

  ###
  @private
  Removes news items that fall below the trending score threshold

  @param newsItems {Array<Object>} list of news items to filter
  @return {Array<Object>} list of news items, filtered by trending score
  ###
  filterNewsByTrendScore = (newsItems) ->
    newsItems.filter (item) -> item.trending_score >= scoreThreshold

  ###
  @private
  Removes news items that have been seen before, determined by a hash of its title

  @param newsItems {Array<Object>} list of news items to filter
  @return {Array<Object>} list of news items, filtered by seen before status
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
          logger.log 'warn', 'Problem persisting storage for item ' + titleHash + ' in a previous cycle - marking as seen'
          seenWhen = [ new Date(Date.now()) ]

      storage.setItem(titleHash, seenWhen)

    return unseen

  ###
  @private
  Makes get call to an API for news about a topic

  @param topic {String} topic to get news about
  @param successCallback {Function} function to call on the success of request
  ###
  getLatestNewsForTopic = (topic, successCallback) ->
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

  ###
  @private
  Stores the resulting news items of a topic
  Waits for the results for all topics before handling

  @param topic {String} topic to get news about
  @param result {Array<Object>} 
  ###
  resultsCallback = (topic, result) ->
    classObj = this
    results[topic] = result

    if (Object.keys(results).length == config.TOPICS.length)
      classObj.logResults results
      finished = true

  ###
  @private
  @note public to allow for unit testing, although marked 'private'

  Logs results of processing
  @note logs with level 'warn'

  @param res {Object} results to log
  ###
  logResults: (res) ->
    logger.log 'warn', res

  ###
  @private
  @note public to allow for unit testing, although marked 'private'

  Logs errors that occur due to a 'bad' response status code

  @param topic {String} topic with bad response status code
  @param statusCode {Number} bad response status code
  ###
  handleBadResponse: (topic, statusCode) ->
    logger.log 'error', 'Response with status code ' + statusCode + ' for topic ' + topic

  ###
  @private
  @note public to allow for unit testing, although marked 'private'

  Logs errors that occur due to a bad request or response

  @param topic {String} topic being processed during error
  @param message {String} error message
  @param httpObjType {String} request or response, depending on when error occurred
  ###
  handleError: (topic, message, httpObjType) ->
    logger.log 'error', 'Problem with ' + httpObjType + ' for topic ' + topic + '... ' + message

  ###
  Starts processing each news topic (asynchronous)
  ###
  getLatest: ->
    results = {}

    logger.log 'info', 'Getting latest trending news items for ' + config.TOPICS.length + ' topic(s)...'
    getLatestNewsForTopic.call(this, topic, resultsCallback) for topic in config.TOPICS


module.exports = TrendingNews
