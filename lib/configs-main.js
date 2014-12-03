var config = require('./config');

/**
  * A module with functions to deal with config settings in program
  *
  * @module configs-main
  * @requires config
*/
var configsMain = exports;

/**
  * Logs all config settings, except for the object stored in config.LOG
  *
  * @method logSettings
  * @memberof configs-main
 */
configsMain.logSettings = function() {
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

/**
  * Redefines config settings according to parameters (provided by user)
  *
  * @param runMode {string} determines logging level and whether to use Nock
  * @param scoreThreshold {number} set the lowest-allowed trending score for any news item
  *
  * @method setByUserInput
  * @memberof configs-main
 */
configsMain.setByUserInput = function(runMode, scoreThreshold) {
  config.RUN_MODE = runMode;
  config.SCORE_THRESHOLD = parseInt(scoreThreshold);

  var logLevelPretty;

  switch (config.RUN_MODE) {
    case 'trace':
      logLevelPretty = 'trace';
      break;
    case 'debug':
      logLevelPretty = 'debug';
      break;
    case 'test':
      logLevelPretty = 'error';
      break;
    case 'prod':
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
