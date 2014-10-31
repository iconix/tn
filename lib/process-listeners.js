var config = require('./config');
var notifications = require('./notifications');
var timers = require('./timers');

/**
  * A module for adding global listeners to the process for main program
  *
  * @module process-listeners
  * @requires config
  * @requires notifications
  * @requires timers
*/
var processListeners = exports;

var onExit = function(signal) {
  timers.session.warn({shutdown_signal: signal}, 'Shutting down process...');

  // non-blocking check if mobile notifications have been sent before exiting
  setInterval(function() {
    if (notifications.haveBeenSent)
      timers.logSessionDuration(timers.session);
      timers.logProcessDuration();

      process.exit();
  }, config.POLL_TO_EXIT_RATE);
}

processListeners.add = function() {
  process.on('SIGINT', function() {
    onExit('SIGINT')
  });

  process.on('SIGTERM', function() {
    onExit('SIGTERM')
  });

  process.on('uncaughtException', function (e) {
      timers.session.info('Aborting process...');
      timers.session.fatal({err: e, type: 'UncaughtException'});

      timers.logSessionDuration(timers.session);
      timers.logProcessDuration();

      process.abort();
  });
}