var clc = require('cli-color');
var instapush = require('instapush');
var nconf = require('nconf');

var TrendingNews = require('./lib/trending-news');
var config = require('./lib/config');
var validateArguments = require('./lib/validate-arguments');

var red = clc.redBright;
var notificationsSent = true;
var trendingNews, callRateIntervalObj, notifyIntervalObj;

nconf.file('instapush_settings.json')
     .env();

instapush.settings({
  token: nconf.get('user_token'),
  id: nconf.get('app_id'),
  secret: nconf.get('app_secret')
});

var addProcessListeners = function() {
  process.on('SIGINT', function() {
      console.log('Shutting down process...');
      
      // non-blocking check if mobile notifications have been sent before exiting
      setInterval(function() {
        if (notificationsSent)
          process.exit();
      }, config.POLL_TO_EXIT_RATE);
  });

  process.on('uncaughtException', function (err) {
      console.error(red('Uncaught Exception...\n' + err.stack));
  });
}

var sendNotifications = function(results) {
  console.log('Sending notifications');

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

      console.log(titleStr);

      instapush.notify({
          'event': 'trend',
          'trackers': {
            'topic': topic,
            'title_str': titleStr
          }
        }, function(err, response) { console.log(response); }
      );
    }
  }

  console.log('Notifications sent!');
  notificationsSent = true;
}

var executeMainLoop = function() {
  console.log('Get latest at ' + new Date(Date.now()));
  notificationsSent = false;
  trendingNews.getLatest();
}

var main = function() {
  var areValidArgs = validateArguments(UserInputOne, UserInputTwo);

  if (areValidArgs)
  {
    addProcessListeners();

    trendingNews = new TrendingNews(UserInputOne, UserInputTwo);
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
}

if (require.main === module) {
  main();
}