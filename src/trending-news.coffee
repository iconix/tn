http = require 'http'
storage = require 'node-persist'
{EventEmitter} = require 'events'
defaultLogger = require('bunyan').createLogger({name: 'tn'})

hashCode = require '../lib/hash-code'
config = require '../lib/config'
require '../lib/mock-index-stream'

###*
  * @classdesc Gets up-to-date, trending news
  *
  * @param [runMode='default'] {string} determines logging level and whether to use Nock
  * @param [scoreThreshold=100] {number} lowest allowed trending score for any news item
  *
  * @example How to create an instance, method 1
  *   new TrendingNews(runMode, scoreThreshold)
  *
  * @example How to create an instance, method 2
  *   new TrendingNews(runMode)
  *
  * @example How to create an instance, method 3
  *   new TrendingNews(scoreThreshold)
  *
  * @property {object} results - latest news results [readonly]
  * @property {object} scoreThreshold - current lowest allowed trending score [readonly]
  *
  * @class TrendingNews
  * @extends EventEmitter
###
class TrendingNews extends EventEmitter

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  # scoreThreshold and results are private shared - among all instances of class
  # (http://book.mixu.net/node/ch6.html)

  # readonly
  scoreThreshold = 100
  get scoreThreshold: -> scoreThreshold

  # readonly
  results = null
  get results: -> results

   # private vars
  classObj = log = session = null

  ###*
    * Constructs a new framework for getting news
    *
    * @constructs TrendingNews
  ###
  constructor: (mode = 'default', score = 100, logger = defaultLogger) ->
    if (!mode)
      mode = 'default'

    if (!score)
      score = 100

    switch mode
      when 'trace' then logLevelPretty = 'trace'
      when 'debug' then logLevelPretty = 'debug'
      when 'prod' then logLevelPretty = 'info'
      when 'test' then logLevelPretty = 'error'
      else logLevelPretty = 'warn'

    log = logger
    log.level logLevelPretty
    log.warn 'in ' + mode +
      'Mode (lowest log level: '+ logLevelPretty + ')'

    switch mode
      when 'prod'
        process.env.NOCK_OFF = true
        log.warn 'Nock is OFF!'
      else log.warn 'Nock is ON'

    scoreThreshold = score
    log.warn 'scoreThreshold = ' + scoreThreshold

  ###*
    * Removes news items that fall below the trending score threshold
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
    * Removes news items that have been seen before, determined by a hash of its title.
    * If there is a problem recording a news item as seen (due to data corruption in a previous
    * cycle), the previous 'seen' history is deleted and lost as the new record is created.
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
      session.debug titleHash + ', ' + item.title
      seenWhen = storage.getItem(titleHash)

      if (seenWhen == undefined)
        unseen.push item
        seenWhen = [ new Date(Date.now()) ]
      else
        try
          seenWhen.push new Date(Date.now())
        catch TypeError
          err = new Error('Problem persisting storage in a previous cycle'
            + ' - restarting the history of this news item')
          err.name = "Storage"
          err.level = "Warning" # means fix below not required to continue
          err.title = item.title
          err.title_hash = titleHash

          session.warn err
          seenWhen = [ new Date(Date.now()) ]

      storage.setItem(titleHash, seenWhen)

    return unseen

  ###*
    * Makes get call to an API for news about a topic.
    * If there is a problem retrieving news for a topic, the results callback
    * is called with an empty list of results.
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
    session.debug 'Getting all news for topic: ' + topic + '...'

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
            err = new Error()
            err.name = "InvalidJSON"
            err.level = "Error" # means fix below required to continue
            err.bad_response = data

            classObj.handleError err, topic, false
            data = {link_list: []}

          allNewsItems = data.link_list # strip topic name and status code
          session.debug '# ' + topic +
            ' items before filter: ' + allNewsItems.length

          # TODO dispatchStorageTask - store all response data asynchronously

          filteredItems = filterNewsByTrendScore allNewsItems
          session.debug '# ' + topic +
            ' items after filter: ' + filteredItems.length

          unseenItems = filterNewsIfSeenBefore filteredItems
          session.debug '# ' + topic +
            ' items never seen before: ' + unseenItems.length

          session.debug '---'

          resultsCallback topic, unseenItems
        else
          err = new Error()
          err.name = "BadStatusCode"
          err.level = "Error"
          err.topic = topic
          err.http_code = response.statusCode

          classObj.handleError err, topic, true
      )

      response.on('error', (e) ->
        err = new Error(e.message)
        err.name = "BadResponse"
        err.level = "Error"
        err.topic = topic

        classObj.handleError err, topic, true
      )
    ).on('error', (e) -> # on request error
      err = new Error(e.message)
      err.name = "BadRequest"
      err.level = "Error"
      err.topic = topic

      classObj.handleError err, topic, true
    )

  ###*
    * Stores the resultant news items of a topic.
    * Waits for the results for all topics before emitting the end event.
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
    results[topic] = result

    if (Object.keys(results).length == config.TOPICS.length)
      classObj.logResults results
      classObj.emit('end', results)

  ###*
    * Logs results at the end of the TrendingNews event cycle.
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
    session.warn res

  ###*
    * For given topic, log error.
    * Can also provide an empty result for topic, if boolean set to true.
    * Public to allow for unit testing, although marked 'private'
    *
    * @param error {Object} Error object with descriptive properties
    * @param topic {String} topic being processed during error
    * @param provideEmptyResult {Boolean} if true, provide empty result for topic to results callback
    *
    * @method handleError
    * @memberof TrendingNews
    * @instance
    * @private
  ###
  handleError: (error, topic, provideEmptyResult) ->
    session.error error
    resultsCallback topic, [] if provideEmptyResult

  ###*
    * Processes every news topic in an asynchronous manner
    *
    * @method getLatest
    * @memberof TrendingNews
    * @instance
  ###
  getLatest: (sesh = defaultLogger) ->
    session = sesh
    session.level log.level()
    classObj = this
    results = {}

    session.info 'Getting latest trending news items for ' +
      config.TOPICS.length + ' topic(s)...'

    for topic in config.TOPICS
      getLatestNewsForTopic topic, resultsCallback

###*
  * A module for the {@link TrendingNews} class
  * @module trending-news
  *
  * @requires hash-code
  * @requires config
  * @requires mock-index-stream
###
module.exports = TrendingNews
