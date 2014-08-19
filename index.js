var util = require('util');
var clc = require('cli-color');
var TrendingNews = require('./lib/trending-news');

var color = clc.redBright;

var one = process.argv[2];
var two = process.argv[3];

module.exports.validateArguments = function(firstArg, secondArg) {
  var firstArgError = "'%s' must be 'debug', 'default', or 'test'!";
  var secondArgError = "'%s' must be a number from 1 to 100!";

  var defaultFirstArg = 'default';
  var defaultSecondArg = 100;

  if (!firstArg && !secondArg)
  {
    one = defaultFirstArg;
    two = defaultSecondArg;
    return true;
  }

  if (parseInt(firstArg))
  {
    if (secondArg)
    {
      console.error(color(util.format(firstArgError, firstArg)));
      console.error(color(util.format('and ' + secondArgError, secondArg)));
      return false;
    }

    if (firstArg < 1 || firstArg > 100)
    {
      console.error(color(util.format(secondArgError, firstArg)));
      return false;
    }

    one = defaultFirstArg;
    two = parseInt(firstArg);
    return true;
  }

  if (firstArg !== 'debug' && firstArg !== 'default' && firstArg !== 'test')
  {
    console.error(color(util.format(firstArgError, firstArg)));
    return false;
  }

  if (!secondArg)
  {
    two = defaultSecondArg;
    return true;
  }

  if (!parseInt(secondArg))
  {
    console.error(color(util.format(secondArgError, secondArg)));
    return false;
  }

  var secondArg = parseInt(secondArg);
  if (secondArg < 1 || secondArg > 100)
  {
    console.error(color(util.format(secondArgError, secondArg)));
    return false;
  }

  return true;
}

var main = function() {
  var areValidArgs = module.exports.validateArguments(one, two);
  var interval = 720000; // 12 minutes

  if (areValidArgs)
  {
    // initial call
    var trendingNews = new TrendingNews(one, two);
    console.log("Get latest at " + new Date(Date.now()));
    trendingNews.getLatest();

    // successive calls
    var intervalObj = setInterval(function() {
      trendingNews = new TrendingNews(one, two);
      console.log("Get latest at " + new Date(Date.now()));
      trendingNews.getLatest();
    }, interval);

    process.on('SIGINT', function() {
      console.log("Shutting down process...");
      
      // non-blocking check if getLatest is finished processing all topics before exiting
      setInterval(function() {
        if (trendingNews.IS_FINISHED)
        {
          clearInterval(intervalObj);
          process.exit();
        }
      }, 1000);
    });

    process.on('uncaughtException', function (err) {
        console.error(color('Uncaught Exception...\n' + err.stack));
    });
  }
}

if (require.main === module) {
  main();
}