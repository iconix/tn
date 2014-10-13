var util = require('util');
var config = require('./config');

var log = config.LOG;

/**
  * @description First argument from the command line
  * @global
*/
UserRunMode = process.argv[2];

/**
  * @description Second argument from the command line
  * @global
*/
UserScoreThreshold = process.argv[3];

/**
  * @description Validates user input on the command line
  *
  * @param [firstArg='default'] {string} @see {@link config#RUN_MODE}
  * @param [secondArg=100] {number} @see {@link config#SCORE_THRESHOLD}
  * @returns {boolean} True, if arguments are valid; false, otherwise.
  *
  * @function validateArguments
  * @private
*/
validateArguments = function(firstArg, secondArg) {
  var firstArgError = "'%s' must be 'debug', 'default', 'test', or 'prod'!";
  var secondArgError = "'%s' must be a number from 1 to 100!";

  var defaultRunMode = 'default';
  var defaultScoreThreshold = 100;

  if (!firstArg && !secondArg)
  { // there are no arguments, set to defaults
    UserRunMode = defaultRunMode;
    UserScoreThreshold = defaultScoreThreshold;
    return true;
  }

  if (parseInt(firstArg))
  { // first arg can only be score threshold

    if (secondArg)
    { // there should not be a second arg
      log.error(util.format(firstArgError, firstArg));
      log.error(util.format('and ' + secondArgError, secondArg));
      return false;
    }

    if (firstArg < 1 || firstArg > 100)
    { // score threshold should be between 1 and 100
      log.error(util.format(secondArgError, firstArg));
      return false;
    }

    UserRunMode = defaultRunMode;
    UserScoreThreshold = parseInt(firstArg);
    return true;
  }

  // at this point: first arg must be run mode,
  // and second arg must be score threshold

  if (firstArg !== 'trace' && firstArg !== 'debug' && firstArg !== 'default' && firstArg !== 'test' && firstArg !== 'prod')
  { // first arg is not a valid run mode
    log.error(util.format(firstArgError, firstArg));
    return false;
  }

  if (!secondArg)
  { // there is no second arg, set to default
    UserScoreThreshold = defaultScoreThreshold;
    return true;
  }

  if (!parseInt(secondArg))
  { // second arg is not a valid score threshold
    log.error(util.format(secondArgError, secondArg));
    return false;
  }

  var secondArg = parseInt(secondArg);
  if (secondArg < 1 || secondArg > 100)
  { // score threshold should be between 1 and 100
    log.error(util.format(secondArgError, secondArg));
    return false;
  }

  // congrats, both arguments survived
  return true;
}

/** 
  * A module for validating user input on the command line
  * @module validate-arguments
  *
  * @requires util
  * @requires config
*/
module.exports = validateArguments;