var clc = require('cli-color');
var instapush = require('instapush');
var TrendingNews = require('./lib/trending-news');
var config = require('./lib/config');
var validateArguments = require('./lib/validate-arguments');

var red = clc.redBright;
var notificationsSent = true;
var trendingNews, callRateIntervalObj, notifyIntervalObj;

// TODO authorize instapush.settings

var addProcessListeners = function() {
  process.on('SIGINT', function() {
      console.log('Shutting down process...');
      
      // non-blocking check if mobile notification has been sent before exiting
      setInterval(function() {
        //if (notificationsSent) TODO use this if statement
        if (trendingNews.finished)
        {
          // TODO probs no reason to clear intervals at this point...
          clearInterval(callRateIntervalObj);
          clearInterval(notifyIntervalObj);
          process.exit();
        }
      }, config.POLL_TO_EXIT_RATE);
  });

  process.on('uncaughtException', function (err) {
      console.error(red('Uncaught Exception...\n' + err.stack));
  });
}

var addNotificationListener = function() {
  // non-blocking check if getLatest is finished processing all topics before sending notification
  notifyIntervalObj = setInterval(function() {
    //if (trendingNews.finished) TODO use this if statement
    if (false)
    {
      console.log('Sending notifications');

      // prevent duplicate send on same results
      trendingNews.finished = false;
      var toNotify = trendingNews.results;
      console.log(toNotify);

      var keys = Object.keys(toNotify);
      // TODO double for-loop?
      for (var tIndex = 0; tIndex < keys.length; tIndex++) {

        var topic = keys[tIndex];
        var topicalNews = toNotify[topic];

        if (topicalNews.length > 0)
        {
          var titleStr = '|';

          for (var nIndex = 0; nIndex < topicalNews.length; nIndex++) {
            var news = topicalNews[nIndex];
            titleStr += ' ' + news.title + ' |';
          }

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

      notificationsSent = true;
    }
  }, config.POLL_TO_NOTIFY_RATE);
}

var executeMainLoop = function() {
  trendingNews = new TrendingNews(UserInputOne, UserInputTwo);
  console.log('Get latest at ' + new Date(Date.now()));
  notificationsSent = false;
  trendingNews.getLatest();
}

var main = function() {
  var areValidArgs = validateArguments(UserInputOne, UserInputTwo);

  if (areValidArgs)
  {
    addProcessListeners();
    addNotificationListener();

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