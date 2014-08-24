var clc = require('cli-color');
var TrendingNews = require('./lib/trending-news');
var config = require('./lib/config');
var validateArguments = require('./lib/validate-arguments');

var red = clc.redBright;
var trendingNews;
var callRateIntervalObj;

var addProcessListeners = function() {
  process.on('SIGINT', function() {
      console.log("Shutting down process...");
      
      // non-blocking check if getLatest is finished processing all topics before exiting
      setInterval(function() {
        if (trendingNews.finished)
        {
          clearInterval(callRateIntervalObj);
          process.exit();
        }
      }, config.POLL_TO_EXIT_RATE);
    });

    process.on('uncaughtException', function (err) {
        console.error(red('Uncaught Exception...\n' + err.stack));
    });
}

var executeMainLoop = function() {
  trendingNews = new TrendingNews(UserInputOne, UserInputTwo);
  console.log("Get latest at " + new Date(Date.now()));
  trendingNews.getLatest();
}

var main = function() {
  var areValidArgs = validateArguments(UserInputOne, UserInputTwo);

  if (areValidArgs)
  {
    addProcessListeners();

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