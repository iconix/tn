var util = require('util');
var clc = require('cli-color');

var red = clc.redBright;

one = process.argv[2]; // global var
two = process.argv[3]; // global var

validateArguments = function(firstArg, secondArg) {
  var firstArgError = "'%s' must be 'debug', 'default', 'test', or 'prod'!";
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
      console.error(red(util.format(firstArgError, firstArg)));
      console.error(red(util.format('and ' + secondArgError, secondArg)));
      return false;
    }

    if (firstArg < 1 || firstArg > 100)
    {
      console.error(red(util.format(secondArgError, firstArg)));
      return false;
    }

    one = defaultFirstArg;
    two = parseInt(firstArg);
    return true;
  }

  if (firstArg !== 'debug' && firstArg !== 'default' && firstArg !== 'test' && firstArg !== 'prod')
  {
    console.error(red(util.format(firstArgError, firstArg)));
    return false;
  }

  if (!secondArg)
  {
    two = defaultSecondArg;
    return true;
  }

  if (!parseInt(secondArg))
  {
    console.error(red(util.format(secondArgError, secondArg)));
    return false;
  }

  var secondArg = parseInt(secondArg);
  if (secondArg < 1 || secondArg > 100)
  {
    console.error(red(util.format(secondArgError, secondArg)));
    return false;
  }

  return true;
}

module.exports = validateArguments;