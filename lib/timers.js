var config = require('./config');

/**
  * A module for dealing with time in this program
  *
  * @module timers
  * @requires config
*/
var timers = exports;

timers.session;
timers.sessionTimer;
timers.processTimer;

timers.logProcessDuration = function() {
  var processDuration = process.hrtime(timers.processTimer);
  config.LOG.info({process_duration_ms:
    (processDuration[0]*1e3 + processDuration[1]/1000000).toFixed(3)});
}

timers.logSessionDuration = function() {
  // check for dummy values
  if (timers.sessionTimer[0] != 0 && timers.sessionTimer[1] != 0)
  {
    var sessionDuration = process.hrtime(timers.sessionTimer);
    timers.session.info({session_duration_ms:
      (sessionDuration[0]*1e3 + sessionDuration[1]/1000000).toFixed(3)});
    timers.sessionTimer = [0, 0]; // reset to dummy
  }
}
