// Generated by CoffeeScript 1.7.1
(function() {
  var getLatestTrends, getTrendForTopic, http, indexStream, topTwtrLists, topics;

  http = require('http');

  indexStream = 'http://trendspottr.com/indexStream.php?q=';

  topics = ['News', 'Technology', 'Content Marketing', 'Infographics', 'Economy', 'Sports', 'Pop Culture', 'Politics', 'Science', 'Celebrity'];

  topTwtrLists = ['https://twitter.com/Scobleizer/lists/tech-pundits', 'https://twitter.com/marshallk/lists/social-strategists', 'https://twitter.com/newscred/lists/content-leaders', 'https://twitter.com/BreakingNews/lists/breaking-news-sources', 'https://twitter.com/journalismnews/lists/social-media-journalism', 'https://twitter.com/nytimes/lists/nyt-journalists', 'https://twitter.com/cspan/lists/members-of-congress', 'https://twitter.com/AskAaronLee/lists/brands', 'https://twitter.com/eonline/lists/celebs-on-twitter', 'https://twitter.com/SInow/lists/si-twitter-100', 'https://twitter.com/getLittleBird/lists/business-finance', 'https://twitter.com/Jason_Pollock/lists/rising-stars'];

  getLatestTrends = function(scoreThreshold) {
    var latestTrends, t, _i, _len;
    if (scoreThreshold == null) {
      scoreThreshold = 100;
    }
    latestTrends = [];
    for (_i = 0, _len = topics.length; _i < _len; _i++) {
      t = topics[_i];
      latestTrends += getTrendForTopic(t);
    }
    return latestTrends;
  };

  getTrendForTopic = function(topic) {
    return http.get(indexStream + topic, function(response) {
      var str;
      console.log("Response code" + response.statusCode);
      str = '';
      response.on('data', function(chunk) {
        return str += chunk;
      });
      return response.on('end', function() {
        return str;
      });
    });
  };

  console.log(getLatestTrends());

}).call(this);
