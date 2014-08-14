var TrendingNews = require('./lib/trending-news');

var trendingNews = new TrendingNews('debug', 80);
trendingNews.getLatest();
