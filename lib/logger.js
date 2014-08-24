/** 
  * A module for logging with 3 levels: info (white), warn (yellow), error (red)
  * [modified from original author]
  *
  * @module logger
  * @author Josh Holbrook, [Nodejitsu: How to log in node.js]{@link http://docs.nodejitsu.com/articles/intermediate/how-to-log}
  * @requires cli-color
*/
var logger = exports;

var clc = require('cli-color');

logger.debugLevel = 'warn';

logger.log = function(level, message) {
  var levels = ['error', 'warn', 'info'];

  var color;
  switch (level)
  {
    case 'error':
      color = clc.redBright;
      break;
    case 'warn':
      color = clc.yellow;
      break;
    default:
      color = clc.white;
  }

  if (levels.indexOf(level) <= levels.indexOf(logger.debugLevel) ) {

    if (typeof message !== 'string') {
      console.log(color(level+': JSON...'));
      console.log(message);
    } else {
      console.log(color(level+': '+message));
    }

  }
}
