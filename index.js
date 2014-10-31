var config = require('./lib/config');
var configsMain = require('./lib/configs-main');
var notifications = require('./lib/notifications');
var processListeners = require('./lib/process-listeners');
var timers = require('./lib/timers');
var TrendingNews = require('./lib/trending-news');
var uuid = require('./lib/uuid');
var validateArguments = require('./lib/validate-arguments');

var log = config.LOG;

var executeMainLoop = function() {
  var session;

  timers.sessionTimer = process.hrtime();
  session = timers.session = log.child({session_id: uuid.generate()});

  var trendingNews = new TrendingNews(session);
  trendingNews.on('end', function(results) {
    notifications.send(session, results.news_items);
  });

  notifications.haveBeenSent = false;
  trendingNews.getLatest();
}

var main = function() {
  timers.processTimer = process.hrtime();
  var areValidArgs = validateArguments(UserRunMode, UserScoreThreshold);

  if (areValidArgs)
  {
    processListeners.add();
    configsMain.setByUserInput(UserRunMode, UserScoreThreshold);
    configsMain.log();

    // initial call
    executeMainLoop();

    // successive calls until process exits or aborts
    setInterval(function() {
      executeMainLoop();
    }, config.CALL_RATE);
  }
  else
  {
    var err = new Error('Aborting process...');
    log.fatal({
      err: err,
      type: 'InvalidArguments',
      first_arg: UserRunMode,
      second_arg: UserScoreThreshold
    });

    timers.logProcessDuration();
    process.abort();
  }
}

if (require.main === module) {
  main();
}