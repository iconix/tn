var util = require('util');
var clc = require('cli-color');
var TrendingNews = require('./lib/trending-news');

var color = clc.redBright;

var one = process.argv[2];
var two = process.argv[3];

var main = function() {
  var areValidArgs = module.exports.validateArguments(one, two);

  if (areValidArgs)
  {
    var trendingNews = new TrendingNews(one, two);
    trendingNews.getLatest();
  }
}

if (require.main === module) {
  main();
}

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