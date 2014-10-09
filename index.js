var instapush = require('instapush');
var nconf = require('nconf');
var uuid = require('node-uuid');
var log = require('bunyan').createLogger({name: 'tn'});

var TrendingNews = require('./lib/trending-news');
var config = require('./lib/config');
var validateArguments = require('./lib/validate-arguments');

var trendingNews, callRateIntervalObj, notifyIntervalObj, session;
var notificationsSent = true;

nconf.file('instapush_settings.json')
     .env();

instapush.settings({
  token: nconf.get('user_token'),
  id: nconf.get('app_id'),
  secret: nconf.get('app_secret')
});

var onExit = function(signal) {
  session.warn('Shutting down process on ' + signal + '...');

  // non-blocking check if mobile notifications have been sent before exiting
  setInterval(function() {
    if (notificationsSent)
      process.exit();
  }, config.POLL_TO_EXIT_RATE);
}

var addProcessListeners = function() {
  process.on('SIGINT', function() {
    onExit('SIGINT')
  });

  process.on('SIGTERM', function() {
    onExit('SIGTERM')
  });

  process.on('uncaughtException', function (e) {
      session.fatal('Aborting process on Uncaught Exception...');
      session.fatal(e);
      process.abort();
  });
}

var sendNotifications = function(results) {
  session.info('Sending notifications');

  var keys = Object.keys(results);
  // TODO double for-loop?
  for (var tIndex = 0; tIndex < keys.length; tIndex++) {

    var topic = keys[tIndex];
    var topicalNews = results[topic];

    if (topicalNews.length > 0)
    {
      var titleStr = '|';

      for (var nIndex = 0; nIndex < topicalNews.length; nIndex++) {
        var news = topicalNews[nIndex];
        titleStr += ' ' + news.title + ' |';
      }

      session.info(titleStr);

      instapush.notify({
          'event': 'trend',
          'trackers': {
            'topic': topic,
            'title_str': titleStr
          }
        }, function(err, response) { session.info(response); }
      );
    }
  }

  session.info('Notifications sent!');
  notificationsSent = true;
}

var generateUuid = function() {
  return uuid.v1(); // timestamp-based UUID
}

var executeMainLoop = function() {
  session = log.child({session_id: generateUuid()});
  notificationsSent = false;
  trendingNews.getLatest(session);
}

var main = function() {
  var areValidArgs = validateArguments(UserRunMode, UserScoreThreshold, log);

  if (areValidArgs)
  {
    addProcessListeners();

    trendingNews = new TrendingNews(UserRunMode, UserScoreThreshold, log);
    trendingNews.on('end', function(results) {
      sendNotifications(results)
    });

    // initial call
    executeMainLoop();

    // successive calls until process exits
    callRateIntervalObj = setInterval(function() {
      executeMainLoop();
    }, config.CALL_RATE);
  }
  else
  {
    var err = new Error('Aborting process');
    err.name = 'InvalidArguments';
    err.level = 'Fatal';
    err.first_arg = UserRunMode;
    err.second_arg = UserScoreThreshold;

    log.fatal(err);
    process.abort();
  }
}

if (require.main === module) {
  main();
}