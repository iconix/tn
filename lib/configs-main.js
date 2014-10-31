var config = require('./config');

/**
  * A module with functions to deal with config settings in program
  *
  * @module configs-main
  * @requires config
*/
var configsMain = exports;

configsMain.log = function() {
  configsToLog = {};
  for (var prop in config)
  {
    // skipping config.LOG since it is a complex object
    if (config.hasOwnProperty(prop) && prop != 'LOG')
    {
      configsToLog[prop] = config[prop];
    }
  }

  config.LOG.info({configs: configsToLog});
}

configsMain.setByUserInput = function(runMode, scoreThreshold) {
  config.RUN_MODE = runMode;
  config.SCORE_THRESHOLD = scoreThreshold;

  var logLevelPretty;

  switch (config.RUN_MODE) {
    case 'trace':
      logLevelPretty = 'trace';
      break;
    case 'debug':
      logLevelPretty = 'debug';
      break;
    case 'prod':
      logLevelPretty = 'info';
      break;
    case 'test':
      logLevelPretty = 'error';
      break;
    default:
      logLevelPretty = 'info';
  }

  if (config.RUN_MODE == 'prod') {
    config.DISABLE_NOCK = true;
    config.STORAGE_DIR = '/data/tn';
    config.SEND_NOTIFICATIONS = true;
  }

  process.env.NOCK_OFF = config.DISABLE_NOCK;
  config.LOG_LEVEL_THRESHOLD = logLevelPretty;
}
