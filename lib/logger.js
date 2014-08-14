// modified from http://docs.nodejitsu.com/articles/intermediate/how-to-log

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
      console.log(color(level+': ...'));
      console.log(color(JSON.stringify(message)));
    } else {
      console.log(color(level+': '+message));
    }

  }
}
