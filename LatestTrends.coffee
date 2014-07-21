http = require('http')
mockIndexStream = require('./mockIndexStream')

indexStream = 'http://trendspottr.com/indexStream.php?q='

topics = [
    'News'
    'Technology'
    'Content Marketing'
    'Infographics'
    'Economy'
    'Sports'
    'Pop Culture'
    'Politics'
    'Science'
    'Celebrity'
]

topTwtrLists = [
    'https://twitter.com/Scobleizer/lists/tech-pundits'
    'https://twitter.com/marshallk/lists/social-strategists'
    'https://twitter.com/newscred/lists/content-leaders'
    'https://twitter.com/BreakingNews/lists/breaking-news-sources'
    'https://twitter.com/journalismnews/lists/social-media-journalism'
    'https://twitter.com/nytimes/lists/nyt-journalists'
    'https://twitter.com/cspan/lists/members-of-congress'
    'https://twitter.com/AskAaronLee/lists/brands'
    'https://twitter.com/eonline/lists/celebs-on-twitter'
    'https://twitter.com/SInow/lists/si-twitter-100'
    'https://twitter.com/getLittleBird/lists/business-finance'
    #'https://twitter.com/AAPremlall/lists/women-to-follow-18'
    'https://twitter.com/Jason_Pollock/lists/rising-stars'
]

getLatestTrends = (scoreThreshold = 100) ->
    getTrendsForTopic t for t in topics

getTrendsForTopic = (topic) ->
    http.get(indexStream+topic, (response) ->
        str = ''

        response.on('data', (chunk) ->
            str += chunk
        )

        response.on('end', ->
            console.log(str)
        )
    )

getLatestTrends()