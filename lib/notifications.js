var instapush = require('instapush');
var nconf = require('nconf');

var config = require('./config');
var timers = require('./timers');

/**
  * A module for sending push notifications to mobile devices
  *
  * @module notifications
  * @requires instapush
  * @requires nconf
  * @requires config
  * @requires timers
*/
var notifications = exports;

nconf.file('instapush_settings.json')
     .env();

instapush.settings({
  token: nconf.get('user_token'),
  id: nconf.get('app_id'),
  secret: nconf.get('app_secret')
});

notifications.haveBeenSent = true;
var sentSummary, sendAttempts;

var notifyAndLog = function(session, topic, titleStr, numItemsSent) {
  session.debug({topic: topic, notification_content: titleStr});
  if (config.SEND_NOTIFICATIONS)
  {
    instapush.notify({
      'event': 'trend',
      'trackers': {
        'topic': topic,
        'title_str': titleStr
      }
    }, function(err, response) {
      if (response)
      {
        session.info({instapush_response: response});

        if (response.status == 200)
          sentSummary['items_with_notifications'][topic] = numItemsSent;
      }
      else
      {
        session.warn({instapush_error: err});
      }

      sendAttempts++;
    });
  }
  else
  {
    sentSummary['items_with_notifications'][topic] = numItemsSent;
    sendAttempts++;
  }
}

notifications.send = function(session, results) {
  if (config.SEND_NOTIFICATIONS)
    session.info('Sending notifications');
  else
    session.info('Notifications disabled');

  sentSummary = {
    'items_with_notifications': {}
  };

  sendAttempts = 0;
  var keys = Object.keys(results);
  // TODO double for-loop?
  for (var tIndex = 0; tIndex < keys.length; tIndex++) {

    var topic = keys[tIndex];
    var topicalNews = results[topic];

    if (topicalNews.length > 0)
    {
      var titleStr = '|';

      var numItemsSent = 0;
      for (var nIndex = 0; nIndex < topicalNews.length; nIndex++) {
        var news = topicalNews[nIndex];
        titleStr += ' ' + news.title + ' |';
        numItemsSent++;
      }

      notifyAndLog(session, topic, titleStr, numItemsSent);
    }
    else
    {
      sendAttempts++;
    }
  }

  var sendIntervalObj = setInterval(function() {
    if (sendAttempts == keys.length)
    {
      clearInterval(sendIntervalObj);

      if (config.SEND_NOTIFICATIONS)
        session.info('Notifications sent!');

      session.info(sentSummary);
      timers.logSessionDuration();

      notifications.haveBeenSent = true;
    }
  }, config.POLL_TO_EXIT_RATE);
}
