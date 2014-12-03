bunyan = require 'bunyan'
defaultLogger = bunyan.createLogger({
  name: 'tn'
  serializers: {
    err: bunyan.stdSerializers.err
  }
})

# TODO Add checks for writeable configs, ensure they are valid before redefining
define = (name, value, isWritable) ->
  Object.defineProperty exports, name, {
    value: value
    enumerable: true
    configurable: false
    writable: isWritable
  }

###*
  * @description Configures all constant values
  * [modified from original author]
  *
  * @author Dominic Barnes, [Stack Overflow: How do you share constants in Node.js modules?]{@link http://stackoverflow.com/a/8596808}
  * @namespace config
###
config = () ->
  ###*
    * @description List of news topics to request news items for.
    * Writeable to allow for unit testing.
    *
    * @constant TOPICS
    * @memberof config
    * @instance
  ###
  define 'TOPICS', [
      'News'
      'Technology'
      'Infographics'
      'Economy'
      'Sports'
      'Pop Culture'
      'Politics'
      'Science'
      'Celebrity'
  ], true

  ###*
    * @description Storage directory within node_modules/node-persist/persist/.
    * Writeable to allow for unit testing.
    *
    * @constant STORAGE_DIR
    * @memberof config
    * @instance
  ###
  define 'STORAGE_DIR', 'TNStorage', true

  ###*
    * @description Domain name of the news API [readonly]
    *
    * @constant REQUEST_HOSTNAME
    * @memberof config
    * @instance
  ###
  define 'REQUEST_HOSTNAME', 'trendspottr.com', false

  ###*
    * @description Domain pathname of the news API [readonly]
    *
    * @constant REQUEST_PATH
    * @memberof config
    * @instance
  ###
  define 'REQUEST_PATH', '/indexStream.php?q=', false

  ###*
    * @description Request headers to be sent to the news API [readonly]
    *
    * @constant REQUEST_HEADERS
    * @memberof config
    * @instance
  ###
  define 'REQUEST_HEADERS', {
    'Accept': '*/*'
    'Accept-Encoding': 'gzip,deflate,sdch'
    'Accept-Language': 'en-US,en;q=0.8'
    'Cache-Control': 'max-age=0'
    'Connection': 'keep-alive'
    'DNT': '1'
    'Referer': 'http://trendspottr.com/'
    'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 ' +
      '(KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36'
    'X-Requested-With': 'XMLHttpRequest'
  }, false

  ###*
    * @description How often to get latest news, in ms [readonly]
    *
    * @constant CALL_RATE
    * @memberof config
    * @instance
  ###
  define 'CALL_RATE', 720000, false # 12-minute interval

  ###*
    * @description How often to check if it is safe to exit the process after receiving the kill signal [readonly]
    *
    * @constant POLL_TO_EXIT_RATE
    * @memberof config
    * @instance
  ###
  define 'POLL_TO_EXIT_RATE', 1000, false # 1-second interval

  ###*
    * @description Logger object with app name set [readonly]
    *
    * @constant LOG
    * @memberof config
    * @instance
  ###
  define 'LOG', defaultLogger, false

  ###*
    * @description Determines logging level and whether to use Nock. Should be either 'trace', 'debug', 'default', 'test', or 'prod'.
    * Configurable from command line.
    *
    * @constant RUN_MODE
    * @memberof config
    * @instance
  ###
  define 'RUN_MODE', 'default', true

  ###*
    * @description Lowest-allowed trending score for any news item. Should be a number from 1 to 100.
    * Configurable from command line.
    *
    * @constant SCORE_THRESHOLD
    * @memberof config
    * @instance
  ###
  define 'SCORE_THRESHOLD', 100, true

  ###*
    * @description Logger object with app name set.
    * Indirectly configurable from command line via RUN_MODE.
    *
    * @constant LOG_LEVEL_THRESHOLD
    * @memberof config
    * @instance
  ###
  define 'LOG_LEVEL_THRESHOLD', 'info', true

  ###*
    * @description Determines whether to send notifications to mobile.
    * Indirectly configurable from command line via RUN_MODE
    * ('prod' mode turns notifications on).
    *
    * @constant SEND_NOTIFICATIONS
    * @memberof config
    * @instance
  ###
  define 'SEND_NOTIFICATIONS', false, true

  ###*
    * @description Determines whether Nock is on and should intercept HTTP requests.
    * Indirectly configurable from command line via RUN_MODE
    * ('prod' mode turns Nock off).
    *
    * @constant DISABLE_NOCK
    * @memberof config
    * @instance
  ###
  define 'DISABLE_NOCK', false, true

config()

###*
  * A module for the {@link config} namespace
  * @module config
  *
  * @requires bunyan
###
