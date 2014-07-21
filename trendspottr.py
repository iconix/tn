from pattern.web import URL
import json

# Trendspottr IndexStream

score_threshold = 100
index_stream = 'http://trendspottr.com/indexStream.php?q='

topics = \
[
	'News',
	'Technology',
	'Content Marketing',
	'Infographics',
	'Economy',
	'Sports',
	'Pop Culture',
	'Politics',
	'Science',
	'Celebrity'
]

top_twtr_lists = \
[
	'https://twitter.com/Scobleizer/lists/tech-pundits',
	'https://twitter.com/marshallk/lists/social-strategists',
	'https://twitter.com/newscred/lists/content-leaders',
	'https://twitter.com/BreakingNews/lists/breaking-news-sources',
	'https://twitter.com/journalismnews/lists/social-media-journalism',
	'https://twitter.com/nytimes/lists/nyt-journalists',
	'https://twitter.com/cspan/lists/members-of-congress',
	'https://twitter.com/AskAaronLee/lists/brands',
	'https://twitter.com/eonline/lists/celebs-on-twitter',
	'https://twitter.com/SInow/lists/si-twitter-100',
	'https://twitter.com/getLittleBird/lists/business-finance',
	#'https://twitter.com/AAPremlall/lists/women-to-follow-18',
	'https://twitter.com/Jason_Pollock/lists/rising-stars'
]

top_trends = []

for topic in topics:
	url = URL(index_stream + topic)
	content = json.loads(url.download())
	trends = content['all_links']['link']
	top_trends += [t for t in trends if t['trending_score'] >= score_threshold]

for l in top_twtr_lists:
	url = URL(index_stream + l)
	content = json.loads(url.download())
	trends = content['all_links']['link']
	top_trends += [t for t in trends if t['trending_score'] >= score_threshold]

# print top_trends
print [t['title'] for t in top_trends]