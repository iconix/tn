var instapush = require('instapush');
var nconf = require('nconf');
var uuid = require('node-uuid');

var TrendingNews = require('./lib/trending-news');
var config = require('./lib/config');
var validateArguments = require('./lib/validate-arguments');

var session, sessionTimer, processTimer;
var log = config.LOG;
var notificationsSent = true;

nconf.file('instapush_settings.json')
     .env();

instapush.settings({
  token: nconf.get('user_token'),
  id: nconf.get('app_id'),
  secret: nconf.get('app_secret')
});

var logProcessDuration = function() {
  var processDuration = process.hrtime(processTimer);
  log.info({process_duration_ms:
    (processDuration[0]*1e3 + processDuration[1]/1000000).toFixed(3)});
}

var logSessionDuration = function() {
  // check for dummy values
  if (sessionTimer[0] != 0 && sessionTimer[1] != 0)
  {
    var sessionDuration = process.hrtime(sessionTimer);
    session.info({session_duration_ms:
      (sessionDuration[0]*1e3 + sessionDuration[1]/1000000).toFixed(3)});
    sessionTimer = [0, 0]; // reset to dummy
  }
}

var onExit = function(signal) {
  session.warn({shutdown_signal: signal}, 'Shutting down process...');

  // non-blocking check if mobile notifications have been sent before exiting
  setInterval(function() {
    if (notificationsSent)
      logSessionDuration();
      logProcessDuration();

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
      session.info('Aborting process...');
      session.fatal({err: e, type: 'UncaughtException'});

      logSessionDuration();
      logProcessDuration();

      process.abort();
  });
}

var sentSummary, sendAttempts;
var reallySend = function(topic, titleStr, numItemsSent) {
  session.debug({topic: topic, notification_content: titleStr});
  if (config.SEND_NOTIFICATIONS)
  {
    instapush.notify({
      'event': 'trend',
      'trackers': {
        'topic': topic,
        'title_str': titleStr
      }
    }, function(err, response) {
      session.debug(response);

      if (response.status == 200)
        sentSummary['items_with_notifications'][topic] = numItemsSent;

      sendAttempts++;
    });
  }
  else
  {
    sentSummary['items_with_notifications'][topic] = numItemsSent;
    sendAttempts++;
  }
}

var sendNotifications = function(results) {
  if (config.SEND_NOTIFICATIONS)
    session.info('Sending notifications');
  else
    session.info('Notifications disabled');

  sentSummary = {
    'items_with_notifications': {}
  };

  sendAttempts = 0;
  var keys = Object.keys(results);
  // TODO double for-loop?
  for (var tIndex = 0; tIndex < keys.length; tIndex++) {

    var topic = keys[tIndex];
    var topicalNews = results[topic];

    if (topicalNews.length > 0)
    {
      var titleStr = '|';

      var numItemsSent = 0;
      for (var nIndex = 0; nIndex < topicalNews.length; nIndex++) {
        var news = topicalNews[nIndex];
        titleStr += ' ' + news.title + ' |';
        numItemsSent++;
      }

      // TODO this function will be inlined once I make sendNotifications a module
      reallySend(topic, titleStr, numItemsSent);
    }
    else
    {
      sendAttempts++;
    }
  }

  var sendIntervalObj = setInterval(function() {
    if (sendAttempts == keys.length)
    {
      clearInterval(sendIntervalObj);

      if (config.SEND_NOTIFICATIONS)
        session.info('Notifications sent!');

      session.info(sentSummary);
      logSessionDuration();

      notificationsSent = true;
    }
  }, config.POLL_TO_EXIT_RATE);
}

var logAllConfigs = function() {
  configsToLog = {};
  for (var prop in config)
  {
    // skipping config.LOG since it is a complex object
    if (config.hasOwnProperty(prop) && prop != 'LOG')
    {
      configsToLog[prop] = config[prop];
    }
  }

  log.info({configs: configsToLog});
}

var setUserConfigs = function(runMode, scoreThreshold) {
  config.RUN_MODE = runMode;
  config.SCORE_THRESHOLD = scoreThreshold;

  switch (config.RUN_MODE) {
    case 'trace':
      logLevelPretty = 'trace';
      break;
    case 'debug':
      logLevelPretty = 'debug';
      break;
    case 'prod':
      logLevelPretty = 'info';
      break;
    case 'test':
      logLevelPretty = 'error';
      break;
    default:
      logLevelPretty = 'info';
  }

  if (config.RUN_MODE == 'prod') {
    config.DISABLE_NOCK = true;
    config.STORAGE_DIR = '/data/tn';
    config.SEND_NOTIFICATIONS = true;
  }

  process.env.NOCK_OFF = config.DISABLE_NOCK;
  config.LOG_LEVEL_THRESHOLD = logLevelPretty;
}

var generateUuid = function() {
  return uuid.v1(); // timestamp-based UUID
}

var executeMainLoop = function() {
  sessionTimer = process.hrtime();
  session = log.child({session_id: generateUuid()});

  var trendingNews = new TrendingNews(session);
  trendingNews.on('end', function(results) {
    sendNotifications(results.news_items);
  });

  notificationsSent = false;
  trendingNews.getLatest();
}

var main = function() {
  processTimer = process.hrtime();
  var areValidArgs = validateArguments(UserRunMode, UserScoreThreshold);

  if (areValidArgs)
  {
    addProcessListeners();
    setUserConfigs(UserRunMode, UserScoreThreshold);
    logAllConfigs();

    // initial call
    executeMainLoop();

    // successive calls until process exits or aborts
    setInterval(function() {
      executeMainLoop();
    }, config.CALL_RATE);
  }
  else
  {
    var err = new Error('Aborting process...');
    log.fatal({
      err: err,
      type: 'InvalidArguments',
      first_arg: UserRunMode,
      second_arg: UserScoreThreshold
    });

    logProcessDuration();
    process.abort();
  }
}

if (require.main === module) {
  main();
}