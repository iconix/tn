var util = require('util');
var clc = require('cli-color');

var red = clc.redBright;

/**
  * @description First argument from the command line
  * @global
*/
UserInputOne = process.argv[2];

/**
  * @description Second argument from the command line
  * @global
*/
UserInputTwo = process.argv[3];

/**
  * @description Validates user input on the command line
  *
  * @param [firstArg='default'] {string} @see {@link TrendingNews#runMode}
  * @param [secondArg=100] {number} @see {@link TrendingNews#scoreThreshold}
  * @returns {boolean} True, if arguments are valid; false, otherwise.
  *
  * @function validateArguments
  * @private
*/
validateArguments = function(firstArg, secondArg) {
  var firstArgError = "'%s' must be 'debug', 'default', 'test', or 'prod'!";
  var secondArgError = "'%s' must be a number from 1 to 100!";

  var defaultFirstArg = 'default';
  var defaultSecondArg = 100;

  if (!firstArg && !secondArg)
  {
    UserInputOne = defaultFirstArg;
    UserInputTwo = defaultSecondArg;
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

    UserInputOne = defaultFirstArg;
    UserInputTwo = parseInt(firstArg);
    return true;
  }

  if (firstArg !== 'debug' && firstArg !== 'default' && firstArg !== 'test' && firstArg !== 'prod')
  {
    console.error(red(util.format(firstArgError, firstArg)));
    return false;
  }

  if (!secondArg)
  {
    UserInputTwo = defaultSecondArg;
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

/** 
  * A module for validating user input on the command line
  *
  * @module validate-arguments
  * @requires cli-color
  * @requires util
*/
module.exports = validateArguments;