http = require 'http'
storage = require 'node-persist'
{EventEmitter} = require 'events'

hashCode = require '../lib/hash-code'
config = require '../lib/config'
require '../lib/mock-index-stream'

###*
  * @classdesc Gets up-to-date, trending news
  *
  * @param [sessionLogger={@link config#LOG}] {object} child logger that will include session_id with every log
  *
  * @example How to create an instance
  *   new TrendingNews(sessionLogger)
  *
  * @property {object} results - latest news results and run statistics [readonly]
  *
  * @class TrendingNews
  * @extends EventEmitter
###
class TrendingNews extends EventEmitter

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  # instObj and session are private shared - among all instances of class
  # (http://book.mixu.net/node/ch6.html)

   # private vars
  instObj = session = null

  # readonly instance var
  get results: -> @_results


  ###*
    * Constructs a new framework for getting news
    *
    * @constructs TrendingNews
  ###
  constructor: (sessionLogger = config.LOG)->
    session = sessionLogger

    session.level config.LOG_LEVEL_THRESHOLD
    instObj = @

    @_results = {
      'items_with_response': {}
      'items_above_score': {}
      'items_not_seen_before': {}
      'news_items': {}
    }

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
    newsItems.filter (item) -> item.trending_score >= config.SCORE_THRESHOLD

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
      session.debug {title_hash: titleHash, title: item.title}
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

            instObj.handleError err, topic, false
            data = {link_list: []}

          allNewsItems = data.link_list # strip topic name and status code
          if allNewsItems.length > 0
            instObj.results['items_with_response'][topic] = allNewsItems.length

          # TODO dispatchStorageTask - store all response data asynchronously

          filteredItems = filterNewsByTrendScore allNewsItems
          if filteredItems.length > 0
            instObj.results['items_above_score'][topic] = filteredItems.length

          unseenItems = filterNewsIfSeenBefore filteredItems
          if unseenItems.length > 0
            instObj.results['items_not_seen_before'][topic] = unseenItems.length

          resultsCallback topic, unseenItems
        else
          err = new Error()
          err.name = "BadStatusCode"
          err.level = "Error"
          err.topic = topic
          err.http_code = response.statusCode

          instObj.handleError err, topic, true
      )

      response.on('error', (e) ->
        err = new Error(e.message)
        err.name = "BadResponse"
        err.level = "Error"
        err.topic = topic

        instObj.handleError err, topic, true
      )
    ).on('error', (e) -> # on request error
      err = new Error(e.message)
      err.name = "BadRequest"
      err.level = "Error"
      err.topic = topic

      instObj.handleError err, topic, true
    )

  ###*
    * Stores the resultant news items of a topic.
    * Waits for the results for all topics before emitting the end event.
    *
    * @param topic {String} topic with news
    * @param result {Array<Object>} news to store
    *
    * @callback TrendingNews~resultsCallback
    * @memberof TrendingNews
    * @instance
    * @private
  ###
  resultsCallback = (topic, result) ->
    res = instObj.results
    res['news_items'][topic] = result

    if (Object.keys(res.news_items).length == config.TOPICS.length)
      # TODO 'off-by-one' bug in node-persist
      res['total_items_stored'] = storage.length() - 1

      instObj.logResults res
      instObj.emit('end', res)

  ###*
    * Logs results at the end of the TrendingNews event cycle.
    * Logs with level 'info', public to allow for unit testing, although marked 'private'
    *
    * @param res {Object} results to log
    *
    * @method logResults
    * @memberof TrendingNews
    * @instance
    * @private
  ###
  logResults: (res) ->
    session.info {results: res}

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
  getLatest: ->
    session.info {num_topics: config.TOPICS.length},
      'Getting latest trending news items...'

    for topic in config.TOPICS
      getLatestNewsForTopic topic, resultsCallback

###*
  * A module for the {@link TrendingNews} class
  * @module trending-news
  *
  * @requires http
  * @requires node-persist
  * @requires events
  *
  * @requires hash-code
  * @requires config
  * @requires mock-index-stream
###
module.exports = TrendingNews
