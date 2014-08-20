define = (name, value, isWritable) ->
    Object.defineProperty exports, name, {
        value: value
        enumerable: true
        configurable: false
        writable: isWritable
    }

define 'TOPICS', [
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
], true

define 'STORAGE_DIR', 'TNStorage', true

define 'REQUEST_HOSTNAME', 'trendspottr.com', false
define 'REQUEST_PATH', '/indexStream.php?q=', false

define 'REQUEST_HEADERS', {
    'Accept': '*/*'
    'Accept-Encoding': 'gzip,deflate,sdch'
    'Accept-Language': 'en-US,en;q=0.8'
    'Cache-Control': 'max-age=0'
    'Connection': 'keep-alive'
    'DNT': '1'  
    'Referer': 'http://trendspottr.com/'
    'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36'
    'X-Requested-With': 'XMLHttpRequest'
}, false

define 'CALL_RATE', 720000, false # 12 minute-interval
define 'POLL_TO_EXIT_RATE', 1000, false # 1 second
