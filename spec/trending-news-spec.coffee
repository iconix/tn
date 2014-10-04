# http://dannorth.net/introducing-bdd/

nock = require 'nock'
storage = require 'node-persist'
TrendingNews = require '../lib/trending-news'
config = require '../lib/config'

httpDelay = 1000 # artifical pause to verify asynchronicity
config.STORAGE_DIR = 'TestStorage'

describe "TrendingNews (basic tests)", ->

  nock('http://trendspottr.com:80')
    .get('/indexStream.php?q=Basic')
    .twice()
    .delayConnection(httpDelay)
    .reply(200, {"status":"OK","query":"Basic","link_list":[{"provider_url":"www.economist.com","description":"FOR a small firm just breaking into foreign markets, it was a big deal: one of Italy's cities wanted a new leisure facility. Then political power shifted and the new council scrapped the project, without any compensation for losses running to around €100,000 ($140,000).","title":"Justice denied?","thumbnail_width":580,"url":"http://www.economist.com/news/europe/21607860-civil-justice-reform-italy-pressingand-difficult-justice-denied","thumbnail_url":"http://cdn.static-economist.com/sites/default/files/imagecache/original-size/images/print-edition/20140719_EUC339.png","version":"1.0","provider_name":"Economist","type":"link","thumbnail_height":530,"trending_score":100,"short_url":"http://econ.st/1qLuAt0"},{"provider_url":"ca.finance.yahoo.com","description":"Watch the video Billionaire John Paul DeJoria launches ROK Mobile on Yahoo Finance. Billionaire John Paul DeJoria tells Yahoo Finance why he's entered the mobile phone market offering a new service with streaming music.","title":"Billionaire John Paul DeJoria launches ROK Mobile","url":"https://ca.finance.yahoo.com/video/billionaire-john-paul-dejoria-launches-123849132.html","version":"1.0","provider_name":"Yahoo","type":"link","thumbnail_url":"/images/economy/3.jpg","trending_score":88,"short_url":"http://fb.me/2OO9jReKG"},{"provider_url":"www.economist.com","description":"SHANGHAI, which already boasts 14 subway lines, a high-speed maglev service, two huge modern airports, some 20 expressways and a bullet-train departure every three minutes, is about to add one more piece of infrastructure-the headquarters of the new BRICS development bank.","title":"Bridges to somewhere","thumbnail_width":595,"url":"http://www.economist.com/news/finance-and-economics/21607831-variable-benefits-investing-infrastructure-bridges-somewhere","thumbnail_url":"http://cdn.static-economist.com/sites/default/files/images/print-edition/20140719_FND000_0.jpg","version":"1.0","provider_name":"Economist","type":"link","thumbnail_height":335,"trending_score":50,"short_url":"http://econ.st/1phKhaf"},{"provider_url":"clickindialife.com","description":"The share of U.S. firms giving pay raises has nearly tripled since last fall, according to a new survey of business economists by the National Association for Business Economics , though official data on U.S. workers' earnings haven't shown any broad acceleration in wage growth.","title":"More Firms Are Handing Out Pay Raises, NABE Survey Finds","url":"http://clickindialife.com/finance/more-firms-are-handing-out-pay-raises-nabe-survey-finds/","thumbnail_width":82,"thumbnail_url":"http://clickindialife.com/wp-content/uploads/2014/07/23063-thumb-82x60.jpg","version":"1.0","provider_name":"Clickindialife","type":"link","thumbnail_height":60,"trending_score":19,"short_url":"http://bit.ly/1u6J9x9"},{"provider_url":"blogs.hbr.org","description":"When Raja Rajamannar became CMO of MasterCard Worldwide in 2013, he moved quickly to transform how the credit card giant measures marketing. His artillery: Advanced Big Data analytics. MasterCard had always been a data-driven organization. But the real power and full potential of data was not being fully realized by marketing.","title":"How Big Data Brings Marketing and Finance Together","author_name":"Harvard Business Review","thumbnail_width":440,"url":"http://blogs.hbr.org/2014/07/how-big-data-brings-marketing-and-finance-together/","author_url":"https://blogs.hbr.org/author/mwagnerhbr-2/","version":"1.0","provider_name":"HBR Blog Network - Harvard Business Review","thumbnail_url":"https://i1.wp.com/hbrblogs.files.wordpress.com/2014/07/20140718_2.jpg?fit=440%2C330","type":"link","thumbnail_height":163,"trending_score":12,"short_url":"http://s.hbr.org/1teJtFS"},{"provider_url":"www.worldbulletin.net","description":"World Bulletin / News Desk Israel's Finance Minister Yair Lapid has warned that the world, United States included, is losing sympathy and patience with Israel Speaking to a group of representatives from American Jewish organizations on Monday, Yesh Atid party chairman Lapid warned that the increasing boycott campaigns against Israel will have devastating effects on the economy.","title":"Israeli finance minister expresses boycott fears - World Bulletin","thumbnail_width":570,"url":"http://www.worldbulletin.net/haber/129176/israeli-finance-minister-expresses-boycott-fears","thumbnail_url":"http://media.worldbulletin.net/news/2014/02/18/1-rtr2w1et.jpg","version":"1.0","provider_name":"Worldbulletin","type":"link","thumbnail_height":329,"trending_score":11,"short_url":"http://tinyurl.com/pd4dava"},{"provider_url":"www.reuters.com","description":"Credit: Reuters/Fred Prouser Two construction workers are shown standing on scaffolding at an apartment building under construction in Hollywood, California November 12, 2009. The National Association for Business Economics' (NABE) latest business conditions survey found that 43 percent of the 79 economists who participated said their firms had increased wages.","title":"NABE survey points to rising U.S. wage pressures","thumbnail_width":130,"url":"http://www.reuters.com/article/2014/07/21/us-usa-economy-wages-idUSKBN0FQ06X20140721","thumbnail_url":"http://s2.reutersmedia.net/resources/r/?m=02&d=20140721&t=2&i=940154158&w=130&fh=&fw=&ll=&pl=&r=LYNXMPEA6K03B","version":"1.0","provider_name":"Reuters","type":"link","thumbnail_height":84,"trending_score":11,"short_url":"http://bit.ly/1ptJ1Rn"},{"provider_url":"www.fastcompany.com","description":"When Oakland, California-based entrepreneur Jenn Aubert looked at her bookshelf, she had lots of books on business and social media, but noticed all of them were written by men. Seeking to supplement her library with books by women business owners, Aubert visited an online forum for women entrepreneurs and asked three questions.","title":"What Does The Next Generation Of Women Entrepreneurs Look Like?","author_name":"Lindsay LaVine","thumbnail_width":620,"url":"http://www.fastcompany.com/3032989/strong-female-lead/what-does-the-next-generation-of-women-entrepreneurs-look-like","thumbnail_url":"http://d.fastcompany.net/multisite_files/fastcompany/imagecache/620x350/poster/2014/07/3032989-poster-p-5-what-does-the-next-generation-of-women-entrepreneurs-look-like.jpg","author_url":"http://www.fastcompany.com/user/lindsay-lavine","version":"1.0","provider_name":"Fastcompany","type":"link","thumbnail_height":350,"trending_score":10,"short_url":"http://ow.ly/zm8GZ"},{"provider_url":"www.bostonglobe.com","description":"MOSCOW - Russia's richest businessmen are increasingly frantic that President Vladimir Putin's policies in Ukraine will lead to crippling sanctions and are too scared of reprisal to say so publicly, billionaires and analysts said.","title":"Russian billionaires 'in horror' as Putin risks global isolation - The Boston Globe","thumbnail_width":200,"url":"http://www.bostonglobe.com/news/world/2014/07/20/russian-billionaires-horror-putin-risks-global-isolation/yf5vASzFeoGpy2ZLHFKzEM/story.html","thumbnail_url":"http://c.o0bg.com/rw/SysConfig/WebPortal/BostonGlobe/Framework/images/logo-bg-small-square.jpg","version":"1.0","provider_name":"Bostonglobe","type":"link","thumbnail_height":200,"trending_score":10,"short_url":"http://www.bostonglobe.com/news/world/2014/07/20/russian-billionaires-horror-putin-risks-global-isolation/yf5vASzFeoGpy2ZLHFKzEM/story.html"},{"provider_url":"www.japantimes.co.jp","description":"Empowering elderly people in Japan's aging society is the key to reviving and sustaining economic growth in the world's third-largest economy, according to the head of a think tank unit of the Asian Development Bank.","title":"Empowering elderly people key to Japan's growth: ADB think tank chief | The Japan Times","thumbnail_width":870,"url":"http://www.japantimes.co.jp/news/2014/07/21/business/economy-business/empowering-elderly-people-key-to-japans-growth-adb-think-tank-chief/","thumbnail_url":"http://jto.s3.amazonaws.com/wp-content/uploads/2014/07/n-adb-a-20140722-870x1160.jpg","version":"1.0","provider_name":"Japantimes","type":"link","thumbnail_height":1160,"trending_score":9,"short_url":"http://bit.ly/1wOSHbS"},{"provider_url":"finance.townhall.com","description":"n a recent interview with ABC News, Attorney General Eric Holder spewed more racist nonsense. He claimed that some of his critics and the President's critics were motivated by \"racial animus.\" According to Holder, \"There's a certain level of vehemence, it seems to me, that's directed at me [and] directed at the president.","title":"Jeff Crouere - Impeach Eric Holder Now","mean_alpha":107.006666667,"thumbnail_width":300,"url":"http://finance.townhall.com/columnists/jeffcrouere/2014/07/21/impeach-eric-holder-now-n1863929","thumbnail_url":"http://media.townhall.com/_townhall/resources/images/thog.png","version":"1.0","provider_name":"Townhall","type":"link","thumbnail_height":300,"trending_score":8,"short_url":"http://ow.ly/2KrBkE"},{"provider_url":"www.bloomberg.com","description":"Prime Minister Tony Abbott's bid to put Australia back on a path to surplus is under threat from senators opposing A$40 billion ($37.6 billion) in savings. The Liberal-National government, which had wagered on a more compliant upper house when the balance of power switched July 1 to a group of eight center-right lawmakers, has instead seen its spending cuts stymied.","title":"Abbott Australia Surplus Goal at Risk in Budget Impasse: Economy","thumbnail_width":1200,"url":"http://www.bloomberg.com/news/2014-07-21/abbott-australia-surplus-goal-at-risk-in-budget-impasse-economy.html","thumbnail_url":"http://www.bloomberg.com/image/iO83JlX8voPk.jpg","version":"1.0","provider_name":"Bloomberg","type":"link","thumbnail_height":819,"trending_score":7,"short_url":"http://bloom.bg/1k7YUQg"},{"provider_url":"ww1.fnb.mobi","description":"Stand a chance to be 1 of 3 eBucks Millionaires SA's first Banking App is turning 3 and you could win 1 000 000 eBucks every time you transact using the FNB Banking App, each month over the next three months. The more you transact, the greater your chances of winning!","title":"App Birthday Celebration | First National Bank - FNB","url":"http://ww1.fnb.mobi/app-birthday","version":"1.0","provider_name":"Fnb","type":"link","thumbnail_url":"/images/economy/5.jpg","trending_score":7,"short_url":"http://www.fnb.mobi/app-birthday"},{"provider_url":"online.wsj.com","description":"WASHINGTON-U.S. economic activity continued to expand over the summer, with spending on tourism, auto sales and retail sales growing and the country experiencing growth in employment, according to the Federal Reserve's survey of regional economic conditions released Wednesday. Overall, the latest beige book, which describes economic conditions across the central bank's 12 districts from late May through early July, highlighted an...","title":"U.S. Economy Heating Up During Summer","thumbnail_width":200,"url":"http://online.wsj.com/articles/u-s-economy-heating-up-during-summer-1405533636","thumbnail_url":"http://si.wsj.net/img/WSJ_profile_lg.gif","version":"1.0","provider_name":"Wsj","type":"link","thumbnail_height":200,"trending_score":7,"short_url":"http://online.wsj.com/articles/u-s-economy-heating-up-during-summer-1405533636"},{"provider_url":"mondoweiss.net","description":"Two days ago, after four boys were killed by the Israeli military on a Gaza beach in front of the world's media, Israeli Economy Minister Naftali Bennett went on CNN to blame Hamas for their deaths. About 30 second into his interview with Wolf Blitzer above he says that Hamas is \"conducting massive self-genocide.\"","title":"Hasbarapocalyse: Naftali Bennett says Hamas committing 'massive self-genocide'","author_name":"Adam Horowitz","thumbnail_width":200,"url":"http://mondoweiss.net/2014/07/hasbarapocalyse-committing-genocide.html","thumbnail_url":"http://wordpress.com/i/blank.jpg","author_url":"http://mondoweiss.net/author/adamhorowitz","version":"1.0","provider_name":"Mondoweiss","type":"link","thumbnail_height":200,"trending_score":6,"short_url":"http://bit.ly/1oZ6TLa"},{"provider_url":"www.ijreview.com","description":"In December of 2012, speaking in front of a union audience, President Obama was cheered when he claimed that \"right-to-work\" laws - laws that allow employees to decide for themselves whether to join a union - were all about politics and had nothing to do with economics.","title":"Right-To-Work Study Destroys Obama's Claim That Forcing Americans To Join Unions Helps The Economy","mean_alpha":254.962732919,"thumbnail_width":707,"url":"http://www.ijreview.com/2014/07/158900-policy-fail-new-study-destroys-obamas-union-backed-claims-right-work-laws23/","thumbnail_url":"http://static.ijreview.com/wp-content/uploads/2014/07/Map-of-Right-to-Work-States1.png?13a420","version":"1.0","provider_name":"Ijreview","type":"link","thumbnail_height":483,"trending_score":6,"short_url":"http://www.ijreview.com/2014/07/158900-policy-fail-new-study-destroys-obamas-union-backed-claims-right-work-laws23/"},{"provider_url":"www.bloomberg.com","description":"Almost half of all finance professionals expect bonuses to be smaller this year, if they get one at all, according to a Bloomberg Global Poll. Twenty-seven percent of those surveyed said they foresee this year's payout dropping compared with 2013, while 18 percent said they don't expect one, according to the quarterly poll of 562 investors, analysts and traders who are Bloomberg subscribers.","title":"Finance Industry Bonus Hit in Poll as Revenue Disappoints","url":"http://www.bloomberg.com/news/2014-07-20/finance-industry-bonus-hit-in-poll-as-revenue-disappoints.html","version":"1.0","provider_name":"Bloomberg","type":"link","thumbnail_url":"/images/economy/3.jpg","trending_score":6,"short_url":"http://bloom.bg/UjAeIi"}]},
      { 'cache-control': 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
      'content-type': 'application/json',
      date: 'Mon, 21 Jul 2014 05:23:07 GMT',
      expires: 'Thu, 19 Nov 1981 08:52:00 GMT',
      pragma: 'no-cache',
      server: 'Apache/2.2.27 (Amazon)',
      'set-cookie': [ 'PHPSESSID=0vsiddnoalg0u5t7dkff1lf381; path=/' ],
      'x-powered-by': 'PHP/5.3.14 ZendServer/5.0',
      'transfer-encoding': 'chunked',
      connection: 'keep-alive' })
    .get('/indexStream.php?q=Empty')
    .delayConnection(httpDelay)
    .reply(200, {"status":"OK","query":"Basic","link_list":[]},
      { 'cache-control': 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
      'content-type': 'application/json',
      date: 'Mon, 21 Jul 2014 05:23:07 GMT',
      expires: 'Thu, 19 Nov 1981 08:52:00 GMT',
      pragma: 'no-cache',
      server: 'Apache/2.2.27 (Amazon)',
      'set-cookie': [ 'PHPSESSID=0vsiddnoalg0u5t7dkff1lf381; path=/' ],
      'x-powered-by': 'PHP/5.3.14 ZendServer/5.0',
      'transfer-encoding': 'chunked',
      connection: 'keep-alive' })

  afterEach ->
    storage.clear()

  it 'should call available news api and find 1 news item with score >= 100', (done) ->

    # given
    newsInstance = new TrendingNews 'test'
    config.TOPICS = ['Basic']

    # when
    newsInstance.getLatest()

    # then
    spyOn(newsInstance, 'logResults').andCallFake(() ->
      expect(newsInstance.logResults).toHaveBeenCalled()
      expect(newsInstance.results.Basic.length).toEqual(1)
      done()
    )

  it 'should call available news api and find 3 news items with score >= 50', (done) ->

    newsInstance = new TrendingNews 'test', 50
    config.TOPICS = ['Basic']

    newsInstance.getLatest()

    spyOn(newsInstance, 'logResults').andCallFake(() ->
      expect(newsInstance.logResults).toHaveBeenCalled()
      expect(newsInstance.results.Basic.length).toEqual(3)
      done()
    )

  it 'should handle call to available news api that has 0 news items', (done) ->

    newsInstance = new TrendingNews 'test', 50
    config.TOPICS = ['Empty']

    newsInstance.getLatest()

    spyOn(newsInstance, 'logResults').andCallFake(() ->
      expect(newsInstance.logResults).toHaveBeenCalled()
      expect(newsInstance.results.Empty.length).toEqual(0)
      done()
    )

describe "TrendingNews (tests for when things go wrong)", ->

  nock('http://trendspottr.com:80')
    .get('/indexStream.php?q=Error')
    .delayConnection(httpDelay)
    .reply(404)
    .get('/indexStream.php?q=NotJson')
    .delayConnection(httpDelay)
    .reply(200, 'Status OK, but not a JSON response.',
      { 'cache-control': 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
      'content-type': 'text/plain',
      date: 'Mon, 21 Jul 2014 05:23:07 GMT',
      expires: 'Thu, 19 Nov 1981 08:52:00 GMT',
      pragma: 'no-cache',
      server: 'Apache/2.2.27 (Amazon)',
      'set-cookie': [ 'PHPSESSID=0vsiddnoalg0u5t7dkff1lf381; path=/' ],
      'x-powered-by': 'PHP/5.3.14 ZendServer/5.0',
      'transfer-encoding': 'chunked',
      connection: 'keep-alive' })

  newsInstance = new TrendingNews 'test'

  afterEach ->
    storage.clear()

  it 'should handle news api that cannot be found (404)', (done) ->

    config.TOPICS = ['Error']

    newsInstance.getLatest()

    spyOn(newsInstance, 'handleBadResponse').andCallFake(() ->
      expect(newsInstance.handleBadResponse).toHaveBeenCalled()
      expect(Object.keys(newsInstance.results).length).toEqual(0)
      done()
    )

  it 'should handle bad request to news api', (done) ->

    newsInstance.getLatest()

    spyOn(newsInstance, 'handleError').andCallFake(() ->
      expect(newsInstance.handleError)
        .toHaveBeenCalledWith('Error', 'Nock: No match for request GET http://trendspottr.com/indexStream.php?q=Error ', 'request')
      expect(Object.keys(newsInstance.results).length).toEqual(0)
      done()
    )

  xit 'should handle news api that does not respond', (done) -> # disabled spec

    newsInstance.getLatest()

    spyOn(newsInstance, 'handleError').andCallFake(() ->
      expect(newsInstance.handleError)
        .toHaveBeenCalledWith('Test', 'Nock: No match for request GET http://trendspottr.com/indexStream.php?q=Error ', 'response')
      done()
    )

  it 'should handle news api that does not return JSON', (done) ->

    config.TOPICS = ['NotJson']

    newsInstance.getLatest()

    spyOn(newsInstance, 'logResults').andCallFake(() ->
      expect(newsInstance.logResults).toHaveBeenCalled()
      expect(newsInstance.results.NotJson.length).toEqual(0)
      done()
    )

describe "TrendingNews (tests for 'seen before' mechanism [& persistent storage])", ->

  nock('http://trendspottr.com:80')
    .get('/indexStream.php?q=Seen')
    .twice()
    .delayConnection(httpDelay)
    .reply(200, {"status":"OK","query":"Seen","link_list":[{"provider_url":"www.economist.com","description":"FOR a small firm just breaking into foreign markets, it was a big deal: one of Italy's cities wanted a new leisure facility. Then political power shifted and the new council scrapped the project, without any compensation for losses running to around €100,000 ($140,000).","title":"Justice denied?","thumbnail_width":580,"url":"http://www.economist.com/news/europe/21607860-civil-justice-reform-italy-pressingand-difficult-justice-denied","thumbnail_url":"http://cdn.static-economist.com/sites/default/files/imagecache/original-size/images/print-edition/20140719_EUC339.png","version":"1.0","provider_name":"Economist","type":"link","thumbnail_height":530,"trending_score":100,"short_url":"http://econ.st/1qLuAt0"},{"provider_url":"ca.finance.yahoo.com","description":"Watch the video Billionaire John Paul DeJoria launches ROK Mobile on Yahoo Finance. Billionaire John Paul DeJoria tells Yahoo Finance why he's entered the mobile phone market offering a new service with streaming music.","title":"Billionaire John Paul DeJoria launches ROK Mobile","url":"https://ca.finance.yahoo.com/video/billionaire-john-paul-dejoria-launches-123849132.html","version":"1.0","provider_name":"Yahoo","type":"link","thumbnail_url":"/images/economy/3.jpg","trending_score":88,"short_url":"http://fb.me/2OO9jReKG"},{"provider_url":"www.economist.com","description":"SHANGHAI, which already boasts 14 subway lines, a high-speed maglev service, two huge modern airports, some 20 expressways and a bullet-train departure every three minutes, is about to add one more piece of infrastructure-the headquarters of the new BRICS development bank.","title":"Bridges to somewhere","thumbnail_width":595,"url":"http://www.economist.com/news/finance-and-economics/21607831-variable-benefits-investing-infrastructure-bridges-somewhere","thumbnail_url":"http://cdn.static-economist.com/sites/default/files/images/print-edition/20140719_FND000_0.jpg","version":"1.0","provider_name":"Economist","type":"link","thumbnail_height":335,"trending_score":50,"short_url":"http://econ.st/1phKhaf"},{"provider_url":"clickindialife.com","description":"The share of U.S. firms giving pay raises has nearly tripled since last fall, according to a new survey of business economists by the National Association for Business Economics , though official data on U.S. workers' earnings haven't shown any broad acceleration in wage growth.","title":"More Firms Are Handing Out Pay Raises, NABE Survey Finds","url":"http://clickindialife.com/finance/more-firms-are-handing-out-pay-raises-nabe-survey-finds/","thumbnail_width":82,"thumbnail_url":"http://clickindialife.com/wp-content/uploads/2014/07/23063-thumb-82x60.jpg","version":"1.0","provider_name":"Clickindialife","type":"link","thumbnail_height":60,"trending_score":19,"short_url":"http://bit.ly/1u6J9x9"},{"provider_url":"blogs.hbr.org","description":"When Raja Rajamannar became CMO of MasterCard Worldwide in 2013, he moved quickly to transform how the credit card giant measures marketing. His artillery: Advanced Big Data analytics. MasterCard had always been a data-driven organization. But the real power and full potential of data was not being fully realized by marketing.","title":"How Big Data Brings Marketing and Finance Together","author_name":"Harvard Business Review","thumbnail_width":440,"url":"http://blogs.hbr.org/2014/07/how-big-data-brings-marketing-and-finance-together/","author_url":"https://blogs.hbr.org/author/mwagnerhbr-2/","version":"1.0","provider_name":"HBR Blog Network - Harvard Business Review","thumbnail_url":"https://i1.wp.com/hbrblogs.files.wordpress.com/2014/07/20140718_2.jpg?fit=440%2C330","type":"link","thumbnail_height":163,"trending_score":12,"short_url":"http://s.hbr.org/1teJtFS"},{"provider_url":"www.worldbulletin.net","description":"World Bulletin / News Desk Israel's Finance Minister Yair Lapid has warned that the world, United States included, is losing sympathy and patience with Israel Speaking to a group of representatives from American Jewish organizations on Monday, Yesh Atid party chairman Lapid warned that the increasing boycott campaigns against Israel will have devastating effects on the economy.","title":"Israeli finance minister expresses boycott fears - World Bulletin","thumbnail_width":570,"url":"http://www.worldbulletin.net/haber/129176/israeli-finance-minister-expresses-boycott-fears","thumbnail_url":"http://media.worldbulletin.net/news/2014/02/18/1-rtr2w1et.jpg","version":"1.0","provider_name":"Worldbulletin","type":"link","thumbnail_height":329,"trending_score":11,"short_url":"http://tinyurl.com/pd4dava"},{"provider_url":"www.reuters.com","description":"Credit: Reuters/Fred Prouser Two construction workers are shown standing on scaffolding at an apartment building under construction in Hollywood, California November 12, 2009. The National Association for Business Economics' (NABE) latest business conditions survey found that 43 percent of the 79 economists who participated said their firms had increased wages.","title":"NABE survey points to rising U.S. wage pressures","thumbnail_width":130,"url":"http://www.reuters.com/article/2014/07/21/us-usa-economy-wages-idUSKBN0FQ06X20140721","thumbnail_url":"http://s2.reutersmedia.net/resources/r/?m=02&d=20140721&t=2&i=940154158&w=130&fh=&fw=&ll=&pl=&r=LYNXMPEA6K03B","version":"1.0","provider_name":"Reuters","type":"link","thumbnail_height":84,"trending_score":11,"short_url":"http://bit.ly/1ptJ1Rn"},{"provider_url":"www.fastcompany.com","description":"When Oakland, California-based entrepreneur Jenn Aubert looked at her bookshelf, she had lots of books on business and social media, but noticed all of them were written by men. Seeking to supplement her library with books by women business owners, Aubert visited an online forum for women entrepreneurs and asked three questions.","title":"What Does The Next Generation Of Women Entrepreneurs Look Like?","author_name":"Lindsay LaVine","thumbnail_width":620,"url":"http://www.fastcompany.com/3032989/strong-female-lead/what-does-the-next-generation-of-women-entrepreneurs-look-like","thumbnail_url":"http://d.fastcompany.net/multisite_files/fastcompany/imagecache/620x350/poster/2014/07/3032989-poster-p-5-what-does-the-next-generation-of-women-entrepreneurs-look-like.jpg","author_url":"http://www.fastcompany.com/user/lindsay-lavine","version":"1.0","provider_name":"Fastcompany","type":"link","thumbnail_height":350,"trending_score":10,"short_url":"http://ow.ly/zm8GZ"},{"provider_url":"www.bostonglobe.com","description":"MOSCOW - Russia's richest businessmen are increasingly frantic that President Vladimir Putin's policies in Ukraine will lead to crippling sanctions and are too scared of reprisal to say so publicly, billionaires and analysts said.","title":"Russian billionaires 'in horror' as Putin risks global isolation - The Boston Globe","thumbnail_width":200,"url":"http://www.bostonglobe.com/news/world/2014/07/20/russian-billionaires-horror-putin-risks-global-isolation/yf5vASzFeoGpy2ZLHFKzEM/story.html","thumbnail_url":"http://c.o0bg.com/rw/SysConfig/WebPortal/BostonGlobe/Framework/images/logo-bg-small-square.jpg","version":"1.0","provider_name":"Bostonglobe","type":"link","thumbnail_height":200,"trending_score":10,"short_url":"http://www.bostonglobe.com/news/world/2014/07/20/russian-billionaires-horror-putin-risks-global-isolation/yf5vASzFeoGpy2ZLHFKzEM/story.html"},{"provider_url":"www.japantimes.co.jp","description":"Empowering elderly people in Japan's aging society is the key to reviving and sustaining economic growth in the world's third-largest economy, according to the head of a think tank unit of the Asian Development Bank.","title":"Empowering elderly people key to Japan's growth: ADB think tank chief | The Japan Times","thumbnail_width":870,"url":"http://www.japantimes.co.jp/news/2014/07/21/business/economy-business/empowering-elderly-people-key-to-japans-growth-adb-think-tank-chief/","thumbnail_url":"http://jto.s3.amazonaws.com/wp-content/uploads/2014/07/n-adb-a-20140722-870x1160.jpg","version":"1.0","provider_name":"Japantimes","type":"link","thumbnail_height":1160,"trending_score":9,"short_url":"http://bit.ly/1wOSHbS"},{"provider_url":"finance.townhall.com","description":"n a recent interview with ABC News, Attorney General Eric Holder spewed more racist nonsense. He claimed that some of his critics and the President's critics were motivated by \"racial animus.\" According to Holder, \"There's a certain level of vehemence, it seems to me, that's directed at me [and] directed at the president.","title":"Jeff Crouere - Impeach Eric Holder Now","mean_alpha":107.006666667,"thumbnail_width":300,"url":"http://finance.townhall.com/columnists/jeffcrouere/2014/07/21/impeach-eric-holder-now-n1863929","thumbnail_url":"http://media.townhall.com/_townhall/resources/images/thog.png","version":"1.0","provider_name":"Townhall","type":"link","thumbnail_height":300,"trending_score":8,"short_url":"http://ow.ly/2KrBkE"},{"provider_url":"www.bloomberg.com","description":"Prime Minister Tony Abbott's bid to put Australia back on a path to surplus is under threat from senators opposing A$40 billion ($37.6 billion) in savings. The Liberal-National government, which had wagered on a more compliant upper house when the balance of power switched July 1 to a group of eight center-right lawmakers, has instead seen its spending cuts stymied.","title":"Abbott Australia Surplus Goal at Risk in Budget Impasse: Economy","thumbnail_width":1200,"url":"http://www.bloomberg.com/news/2014-07-21/abbott-australia-surplus-goal-at-risk-in-budget-impasse-economy.html","thumbnail_url":"http://www.bloomberg.com/image/iO83JlX8voPk.jpg","version":"1.0","provider_name":"Bloomberg","type":"link","thumbnail_height":819,"trending_score":7,"short_url":"http://bloom.bg/1k7YUQg"},{"provider_url":"ww1.fnb.mobi","description":"Stand a chance to be 1 of 3 eBucks Millionaires SA's first Banking App is turning 3 and you could win 1 000 000 eBucks every time you transact using the FNB Banking App, each month over the next three months. The more you transact, the greater your chances of winning!","title":"App Birthday Celebration | First National Bank - FNB","url":"http://ww1.fnb.mobi/app-birthday","version":"1.0","provider_name":"Fnb","type":"link","thumbnail_url":"/images/economy/5.jpg","trending_score":7,"short_url":"http://www.fnb.mobi/app-birthday"},{"provider_url":"online.wsj.com","description":"WASHINGTON-U.S. economic activity continued to expand over the summer, with spending on tourism, auto sales and retail sales growing and the country experiencing growth in employment, according to the Federal Reserve's survey of regional economic conditions released Wednesday. Overall, the latest beige book, which describes economic conditions across the central bank's 12 districts from late May through early July, highlighted an...","title":"U.S. Economy Heating Up During Summer","thumbnail_width":200,"url":"http://online.wsj.com/articles/u-s-economy-heating-up-during-summer-1405533636","thumbnail_url":"http://si.wsj.net/img/WSJ_profile_lg.gif","version":"1.0","provider_name":"Wsj","type":"link","thumbnail_height":200,"trending_score":7,"short_url":"http://online.wsj.com/articles/u-s-economy-heating-up-during-summer-1405533636"},{"provider_url":"mondoweiss.net","description":"Two days ago, after four boys were killed by the Israeli military on a Gaza beach in front of the world's media, Israeli Economy Minister Naftali Bennett went on CNN to blame Hamas for their deaths. About 30 second into his interview with Wolf Blitzer above he says that Hamas is \"conducting massive self-genocide.\"","title":"Hasbarapocalyse: Naftali Bennett says Hamas committing 'massive self-genocide'","author_name":"Adam Horowitz","thumbnail_width":200,"url":"http://mondoweiss.net/2014/07/hasbarapocalyse-committing-genocide.html","thumbnail_url":"http://wordpress.com/i/blank.jpg","author_url":"http://mondoweiss.net/author/adamhorowitz","version":"1.0","provider_name":"Mondoweiss","type":"link","thumbnail_height":200,"trending_score":6,"short_url":"http://bit.ly/1oZ6TLa"},{"provider_url":"www.ijreview.com","description":"In December of 2012, speaking in front of a union audience, President Obama was cheered when he claimed that \"right-to-work\" laws - laws that allow employees to decide for themselves whether to join a union - were all about politics and had nothing to do with economics.","title":"Right-To-Work Study Destroys Obama's Claim That Forcing Americans To Join Unions Helps The Economy","mean_alpha":254.962732919,"thumbnail_width":707,"url":"http://www.ijreview.com/2014/07/158900-policy-fail-new-study-destroys-obamas-union-backed-claims-right-work-laws23/","thumbnail_url":"http://static.ijreview.com/wp-content/uploads/2014/07/Map-of-Right-to-Work-States1.png?13a420","version":"1.0","provider_name":"Ijreview","type":"link","thumbnail_height":483,"trending_score":6,"short_url":"http://www.ijreview.com/2014/07/158900-policy-fail-new-study-destroys-obamas-union-backed-claims-right-work-laws23/"},{"provider_url":"www.bloomberg.com","description":"Almost half of all finance professionals expect bonuses to be smaller this year, if they get one at all, according to a Bloomberg Global Poll. Twenty-seven percent of those surveyed said they foresee this year's payout dropping compared with 2013, while 18 percent said they don't expect one, according to the quarterly poll of 562 investors, analysts and traders who are Bloomberg subscribers.","title":"Finance Industry Bonus Hit in Poll as Revenue Disappoints","url":"http://www.bloomberg.com/news/2014-07-20/finance-industry-bonus-hit-in-poll-as-revenue-disappoints.html","version":"1.0","provider_name":"Bloomberg","type":"link","thumbnail_url":"/images/economy/3.jpg","trending_score":6,"short_url":"http://bloom.bg/UjAeIi"}]},
      { 'cache-control': 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
      'content-type': 'application/json',
      date: 'Mon, 21 Jul 2014 05:23:07 GMT',
      expires: 'Thu, 19 Nov 1981 08:52:00 GMT',
      pragma: 'no-cache',
      server: 'Apache/2.2.27 (Amazon)',
      'set-cookie': [ 'PHPSESSID=0vsiddnoalg0u5t7dkff1lf381; path=/' ],
      'x-powered-by': 'PHP/5.3.14 ZendServer/5.0',
      'transfer-encoding': 'chunked',
      connection: 'keep-alive' })
    .get('/indexStream.php?q=Duplicate')
    .delayConnection(httpDelay)
    .reply(200, {"status":"OK","query":"Duplicate","link_list":[{"provider_url":"www.economist.com","description":"FOR a small firm just breaking into foreign markets, it was a big deal: one of Italy's cities wanted a new leisure facility. Then political power shifted and the new council scrapped the project, without any compensation for losses running to around €100,000 ($140,000).","title":"Justice denied?","thumbnail_width":580,"url":"http://www.economist.com/news/europe/21607860-civil-justice-reform-italy-pressingand-difficult-justice-denied","thumbnail_url":"http://cdn.static-economist.com/sites/default/files/imagecache/original-size/images/print-edition/20140719_EUC339.png","version":"1.0","provider_name":"Economist","type":"link","thumbnail_height":530,"trending_score":100,"short_url":"http://econ.st/1qLuAt0"},{"provider_url":"www.economist.com","description":"FOR a small firm just breaking into foreign markets, it was a big deal: one of Italy's cities wanted a new leisure facility. Then political power shifted and the new council scrapped the project, without any compensation for losses running to around €100,000 ($140,000).","title":"Justice denied?","thumbnail_width":580,"url":"http://www.economist.com/news/europe/21607860-civil-justice-reform-italy-pressingand-difficult-justice-denied","thumbnail_url":"http://cdn.static-economist.com/sites/default/files/imagecache/original-size/images/print-edition/20140719_EUC339.png","version":"1.0","provider_name":"Economist","type":"link","thumbnail_height":530,"trending_score":100,"short_url":"http://econ.st/1qLuAt0"}]},
      { 'cache-control': 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
      'content-type': 'application/json',
      date: 'Mon, 21 Jul 2014 05:23:07 GMT',
      expires: 'Thu, 19 Nov 1981 08:52:00 GMT',
      pragma: 'no-cache',
      server: 'Apache/2.2.27 (Amazon)',
      'set-cookie': [ 'PHPSESSID=0vsiddnoalg0u5t7dkff1lf381; path=/' ],
      'x-powered-by': 'PHP/5.3.14 ZendServer/5.0',
      'transfer-encoding': 'chunked',
      connection: 'keep-alive' })

  afterEach ->
    storage.clear()

  it 'should call news api twice with same items and store exactly one copy of each item', (done) ->

    newsInstance = new TrendingNews 'test', 50
    config.TOPICS = ['Seen']
    numCalls = 0

    newsInstance.getLatest()
    newsInstance.getLatest()

    spyOn(newsInstance, "logResults").andCallFake((res) ->
      expect(newsInstance.logResults).toHaveBeenCalled()

      if (numCalls == 0)
        expect(newsInstance.results.Seen.length).toEqual(3)
      
      if (numCalls == 1)
        expect(newsInstance.results.Seen.length).toEqual(0)

      numCalls++

      done()
    )

  it 'should call news api with duplicate news item and store exactly one copy of item', (done) ->

    newsInstance = new TrendingNews 'test'
    config.TOPICS = ['Duplicate']

    newsInstance.getLatest()

    spyOn(newsInstance, "logResults").andCallFake((res) ->
      expect(newsInstance.logResults).toHaveBeenCalled()
      expect(newsInstance.results.Duplicate.length).toEqual(1)
      done()
    )

describe "TrendingNews (tests with multiple topics)", ->

  nock('http://trendspottr.com:80')
    .get('/indexStream.php?q=NotFine')
    .delayConnection(httpDelay)
    .reply(404)
    .get('/indexStream.php?q=Fine')
    .twice()
    .delayConnection(httpDelay)
    .reply(200, {"status":"OK","query":"Basic","link_list":[{"provider_url":"www.economist.com","description":"FOR a small firm just breaking into foreign markets, it was a big deal: one of Italy's cities wanted a new leisure facility. Then political power shifted and the new council scrapped the project, without any compensation for losses running to around €100,000 ($140,000).","title":"Justice denied?","thumbnail_width":580,"url":"http://www.economist.com/news/europe/21607860-civil-justice-reform-italy-pressingand-difficult-justice-denied","thumbnail_url":"http://cdn.static-economist.com/sites/default/files/imagecache/original-size/images/print-edition/20140719_EUC339.png","version":"1.0","provider_name":"Economist","type":"link","thumbnail_height":530,"trending_score":100,"short_url":"http://econ.st/1qLuAt0"},{"provider_url":"ca.finance.yahoo.com","description":"Watch the video Billionaire John Paul DeJoria launches ROK Mobile on Yahoo Finance. Billionaire John Paul DeJoria tells Yahoo Finance why he's entered the mobile phone market offering a new service with streaming music.","title":"Billionaire John Paul DeJoria launches ROK Mobile","url":"https://ca.finance.yahoo.com/video/billionaire-john-paul-dejoria-launches-123849132.html","version":"1.0","provider_name":"Yahoo","type":"link","thumbnail_url":"/images/economy/3.jpg","trending_score":88,"short_url":"http://fb.me/2OO9jReKG"},{"provider_url":"www.economist.com","description":"SHANGHAI, which already boasts 14 subway lines, a high-speed maglev service, two huge modern airports, some 20 expressways and a bullet-train departure every three minutes, is about to add one more piece of infrastructure-the headquarters of the new BRICS development bank.","title":"Bridges to somewhere","thumbnail_width":595,"url":"http://www.economist.com/news/finance-and-economics/21607831-variable-benefits-investing-infrastructure-bridges-somewhere","thumbnail_url":"http://cdn.static-economist.com/sites/default/files/images/print-edition/20140719_FND000_0.jpg","version":"1.0","provider_name":"Economist","type":"link","thumbnail_height":335,"trending_score":50,"short_url":"http://econ.st/1phKhaf"},{"provider_url":"clickindialife.com","description":"The share of U.S. firms giving pay raises has nearly tripled since last fall, according to a new survey of business economists by the National Association for Business Economics , though official data on U.S. workers' earnings haven't shown any broad acceleration in wage growth.","title":"More Firms Are Handing Out Pay Raises, NABE Survey Finds","url":"http://clickindialife.com/finance/more-firms-are-handing-out-pay-raises-nabe-survey-finds/","thumbnail_width":82,"thumbnail_url":"http://clickindialife.com/wp-content/uploads/2014/07/23063-thumb-82x60.jpg","version":"1.0","provider_name":"Clickindialife","type":"link","thumbnail_height":60,"trending_score":19,"short_url":"http://bit.ly/1u6J9x9"},{"provider_url":"blogs.hbr.org","description":"When Raja Rajamannar became CMO of MasterCard Worldwide in 2013, he moved quickly to transform how the credit card giant measures marketing. His artillery: Advanced Big Data analytics. MasterCard had always been a data-driven organization. But the real power and full potential of data was not being fully realized by marketing.","title":"How Big Data Brings Marketing and Finance Together","author_name":"Harvard Business Review","thumbnail_width":440,"url":"http://blogs.hbr.org/2014/07/how-big-data-brings-marketing-and-finance-together/","author_url":"https://blogs.hbr.org/author/mwagnerhbr-2/","version":"1.0","provider_name":"HBR Blog Network - Harvard Business Review","thumbnail_url":"https://i1.wp.com/hbrblogs.files.wordpress.com/2014/07/20140718_2.jpg?fit=440%2C330","type":"link","thumbnail_height":163,"trending_score":12,"short_url":"http://s.hbr.org/1teJtFS"},{"provider_url":"www.worldbulletin.net","description":"World Bulletin / News Desk Israel's Finance Minister Yair Lapid has warned that the world, United States included, is losing sympathy and patience with Israel Speaking to a group of representatives from American Jewish organizations on Monday, Yesh Atid party chairman Lapid warned that the increasing boycott campaigns against Israel will have devastating effects on the economy.","title":"Israeli finance minister expresses boycott fears - World Bulletin","thumbnail_width":570,"url":"http://www.worldbulletin.net/haber/129176/israeli-finance-minister-expresses-boycott-fears","thumbnail_url":"http://media.worldbulletin.net/news/2014/02/18/1-rtr2w1et.jpg","version":"1.0","provider_name":"Worldbulletin","type":"link","thumbnail_height":329,"trending_score":11,"short_url":"http://tinyurl.com/pd4dava"},{"provider_url":"www.reuters.com","description":"Credit: Reuters/Fred Prouser Two construction workers are shown standing on scaffolding at an apartment building under construction in Hollywood, California November 12, 2009. The National Association for Business Economics' (NABE) latest business conditions survey found that 43 percent of the 79 economists who participated said their firms had increased wages.","title":"NABE survey points to rising U.S. wage pressures","thumbnail_width":130,"url":"http://www.reuters.com/article/2014/07/21/us-usa-economy-wages-idUSKBN0FQ06X20140721","thumbnail_url":"http://s2.reutersmedia.net/resources/r/?m=02&d=20140721&t=2&i=940154158&w=130&fh=&fw=&ll=&pl=&r=LYNXMPEA6K03B","version":"1.0","provider_name":"Reuters","type":"link","thumbnail_height":84,"trending_score":11,"short_url":"http://bit.ly/1ptJ1Rn"},{"provider_url":"www.fastcompany.com","description":"When Oakland, California-based entrepreneur Jenn Aubert looked at her bookshelf, she had lots of books on business and social media, but noticed all of them were written by men. Seeking to supplement her library with books by women business owners, Aubert visited an online forum for women entrepreneurs and asked three questions.","title":"What Does The Next Generation Of Women Entrepreneurs Look Like?","author_name":"Lindsay LaVine","thumbnail_width":620,"url":"http://www.fastcompany.com/3032989/strong-female-lead/what-does-the-next-generation-of-women-entrepreneurs-look-like","thumbnail_url":"http://d.fastcompany.net/multisite_files/fastcompany/imagecache/620x350/poster/2014/07/3032989-poster-p-5-what-does-the-next-generation-of-women-entrepreneurs-look-like.jpg","author_url":"http://www.fastcompany.com/user/lindsay-lavine","version":"1.0","provider_name":"Fastcompany","type":"link","thumbnail_height":350,"trending_score":10,"short_url":"http://ow.ly/zm8GZ"},{"provider_url":"www.bostonglobe.com","description":"MOSCOW - Russia's richest businessmen are increasingly frantic that President Vladimir Putin's policies in Ukraine will lead to crippling sanctions and are too scared of reprisal to say so publicly, billionaires and analysts said.","title":"Russian billionaires 'in horror' as Putin risks global isolation - The Boston Globe","thumbnail_width":200,"url":"http://www.bostonglobe.com/news/world/2014/07/20/russian-billionaires-horror-putin-risks-global-isolation/yf5vASzFeoGpy2ZLHFKzEM/story.html","thumbnail_url":"http://c.o0bg.com/rw/SysConfig/WebPortal/BostonGlobe/Framework/images/logo-bg-small-square.jpg","version":"1.0","provider_name":"Bostonglobe","type":"link","thumbnail_height":200,"trending_score":10,"short_url":"http://www.bostonglobe.com/news/world/2014/07/20/russian-billionaires-horror-putin-risks-global-isolation/yf5vASzFeoGpy2ZLHFKzEM/story.html"},{"provider_url":"www.japantimes.co.jp","description":"Empowering elderly people in Japan's aging society is the key to reviving and sustaining economic growth in the world's third-largest economy, according to the head of a think tank unit of the Asian Development Bank.","title":"Empowering elderly people key to Japan's growth: ADB think tank chief | The Japan Times","thumbnail_width":870,"url":"http://www.japantimes.co.jp/news/2014/07/21/business/economy-business/empowering-elderly-people-key-to-japans-growth-adb-think-tank-chief/","thumbnail_url":"http://jto.s3.amazonaws.com/wp-content/uploads/2014/07/n-adb-a-20140722-870x1160.jpg","version":"1.0","provider_name":"Japantimes","type":"link","thumbnail_height":1160,"trending_score":9,"short_url":"http://bit.ly/1wOSHbS"},{"provider_url":"finance.townhall.com","description":"n a recent interview with ABC News, Attorney General Eric Holder spewed more racist nonsense. He claimed that some of his critics and the President's critics were motivated by \"racial animus.\" According to Holder, \"There's a certain level of vehemence, it seems to me, that's directed at me [and] directed at the president.","title":"Jeff Crouere - Impeach Eric Holder Now","mean_alpha":107.006666667,"thumbnail_width":300,"url":"http://finance.townhall.com/columnists/jeffcrouere/2014/07/21/impeach-eric-holder-now-n1863929","thumbnail_url":"http://media.townhall.com/_townhall/resources/images/thog.png","version":"1.0","provider_name":"Townhall","type":"link","thumbnail_height":300,"trending_score":8,"short_url":"http://ow.ly/2KrBkE"},{"provider_url":"www.bloomberg.com","description":"Prime Minister Tony Abbott's bid to put Australia back on a path to surplus is under threat from senators opposing A$40 billion ($37.6 billion) in savings. The Liberal-National government, which had wagered on a more compliant upper house when the balance of power switched July 1 to a group of eight center-right lawmakers, has instead seen its spending cuts stymied.","title":"Abbott Australia Surplus Goal at Risk in Budget Impasse: Economy","thumbnail_width":1200,"url":"http://www.bloomberg.com/news/2014-07-21/abbott-australia-surplus-goal-at-risk-in-budget-impasse-economy.html","thumbnail_url":"http://www.bloomberg.com/image/iO83JlX8voPk.jpg","version":"1.0","provider_name":"Bloomberg","type":"link","thumbnail_height":819,"trending_score":7,"short_url":"http://bloom.bg/1k7YUQg"},{"provider_url":"ww1.fnb.mobi","description":"Stand a chance to be 1 of 3 eBucks Millionaires SA's first Banking App is turning 3 and you could win 1 000 000 eBucks every time you transact using the FNB Banking App, each month over the next three months. The more you transact, the greater your chances of winning!","title":"App Birthday Celebration | First National Bank - FNB","url":"http://ww1.fnb.mobi/app-birthday","version":"1.0","provider_name":"Fnb","type":"link","thumbnail_url":"/images/economy/5.jpg","trending_score":7,"short_url":"http://www.fnb.mobi/app-birthday"},{"provider_url":"online.wsj.com","description":"WASHINGTON-U.S. economic activity continued to expand over the summer, with spending on tourism, auto sales and retail sales growing and the country experiencing growth in employment, according to the Federal Reserve's survey of regional economic conditions released Wednesday. Overall, the latest beige book, which describes economic conditions across the central bank's 12 districts from late May through early July, highlighted an...","title":"U.S. Economy Heating Up During Summer","thumbnail_width":200,"url":"http://online.wsj.com/articles/u-s-economy-heating-up-during-summer-1405533636","thumbnail_url":"http://si.wsj.net/img/WSJ_profile_lg.gif","version":"1.0","provider_name":"Wsj","type":"link","thumbnail_height":200,"trending_score":7,"short_url":"http://online.wsj.com/articles/u-s-economy-heating-up-during-summer-1405533636"},{"provider_url":"mondoweiss.net","description":"Two days ago, after four boys were killed by the Israeli military on a Gaza beach in front of the world's media, Israeli Economy Minister Naftali Bennett went on CNN to blame Hamas for their deaths. About 30 second into his interview with Wolf Blitzer above he says that Hamas is \"conducting massive self-genocide.\"","title":"Hasbarapocalyse: Naftali Bennett says Hamas committing 'massive self-genocide'","author_name":"Adam Horowitz","thumbnail_width":200,"url":"http://mondoweiss.net/2014/07/hasbarapocalyse-committing-genocide.html","thumbnail_url":"http://wordpress.com/i/blank.jpg","author_url":"http://mondoweiss.net/author/adamhorowitz","version":"1.0","provider_name":"Mondoweiss","type":"link","thumbnail_height":200,"trending_score":6,"short_url":"http://bit.ly/1oZ6TLa"},{"provider_url":"www.ijreview.com","description":"In December of 2012, speaking in front of a union audience, President Obama was cheered when he claimed that \"right-to-work\" laws - laws that allow employees to decide for themselves whether to join a union - were all about politics and had nothing to do with economics.","title":"Right-To-Work Study Destroys Obama's Claim That Forcing Americans To Join Unions Helps The Economy","mean_alpha":254.962732919,"thumbnail_width":707,"url":"http://www.ijreview.com/2014/07/158900-policy-fail-new-study-destroys-obamas-union-backed-claims-right-work-laws23/","thumbnail_url":"http://static.ijreview.com/wp-content/uploads/2014/07/Map-of-Right-to-Work-States1.png?13a420","version":"1.0","provider_name":"Ijreview","type":"link","thumbnail_height":483,"trending_score":6,"short_url":"http://www.ijreview.com/2014/07/158900-policy-fail-new-study-destroys-obamas-union-backed-claims-right-work-laws23/"},{"provider_url":"www.bloomberg.com","description":"Almost half of all finance professionals expect bonuses to be smaller this year, if they get one at all, according to a Bloomberg Global Poll. Twenty-seven percent of those surveyed said they foresee this year's payout dropping compared with 2013, while 18 percent said they don't expect one, according to the quarterly poll of 562 investors, analysts and traders who are Bloomberg subscribers.","title":"Finance Industry Bonus Hit in Poll as Revenue Disappoints","url":"http://www.bloomberg.com/news/2014-07-20/finance-industry-bonus-hit-in-poll-as-revenue-disappoints.html","version":"1.0","provider_name":"Bloomberg","type":"link","thumbnail_url":"/images/economy/3.jpg","trending_score":6,"short_url":"http://bloom.bg/UjAeIi"}]},
      { 'cache-control': 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
      'content-type': 'application/json',
      date: 'Mon, 21 Jul 2014 05:23:07 GMT',
      expires: 'Thu, 19 Nov 1981 08:52:00 GMT',
      pragma: 'no-cache',
      server: 'Apache/2.2.27 (Amazon)',
      'set-cookie': [ 'PHPSESSID=0vsiddnoalg0u5t7dkff1lf381; path=/' ],
      'x-powered-by': 'PHP/5.3.14 ZendServer/5.0',
      'transfer-encoding': 'chunked',
      connection: 'keep-alive' })

  newsInstance = new TrendingNews 'test'

  afterEach ->
    storage.clear()

  it 'should handle news api that has both good and bad responses', (done) ->

    config.TOPICS = ['Fine', 'NotFine']

    newsInstance.getLatest()

    numRequestsProcessed = 0

    spyOn(newsInstance, 'logResults').andCallFake(() ->
      expect(newsInstance.logResults).toHaveBeenCalled()

      numRequestsProcessed++
      if (numRequestsProcessed == 2)
        expect(Object.keys(newsInstance.results).length).toEqual(2)
        expect(newsInstance.results.Fine.length).toEqual(1)
        expect(newsInstance.results.NotFine.length).toEqual(0)
      done()
    )

    spyOn(newsInstance, 'handleBadResponse').andCallFake(() ->
      expect(newsInstance.handleBadResponse).toHaveBeenCalled()

      numRequestsProcessed++
      if (numRequestsProcessed == 2)
        expect(Object.keys(newsInstance.results).length).toEqual(2)
        expect(newsInstance.results.Fine.length).toEqual(1)
        expect(newsInstance.results.NotFine.length).toEqual(0)
      done()
    )

  it 'should handle both good and bad requests to news api', (done) ->

    config.TOPICS = ['Fine', 'Error']

    newsInstance.getLatest()

    numRequestsProcessed = 0

    spyOn(newsInstance, 'logResults').andCallFake(() ->
      expect(newsInstance.logResults).toHaveBeenCalled()

      numRequestsProcessed++
      if (numRequestsProcessed == 2)
        expect(Object.keys(newsInstance.results).length).toEqual(2)
        expect(newsInstance.results.Fine.length).toEqual(1)
        expect(newsInstance.results.Error.length).toEqual(0)
      done()
    )

    spyOn(newsInstance, 'handleError').andCallFake(() ->
      expect(newsInstance.handleError)
        .toHaveBeenCalledWith('Error', 'Nock: No match for request GET http://trendspottr.com/indexStream.php?q=Error ', 'request')

      numRequestsProcessed++
      if (numRequestsProcessed == 2)
        expect(Object.keys(newsInstance.results).length).toEqual(2)
        expect(newsInstance.results.Fine.length).toEqual(1)
        expect(newsInstance.results.Error.length).toEqual(0)
      done()
    )

  xit 'should handle news api that does and does not respond', (done) ->

    config.TOPICS = ['Fine', 'Error']

    newsInstance.getLatest()

    numRequestsProcessed = 0

    spyOn(newsInstance, 'logResults').andCallFake(() ->
      expect(newsInstance.logResults).toHaveBeenCalled()

      numRequestsProcessed++
      if (numRequestsProcessed == 2)
        expect(Object.keys(newsInstance.results).length).toEqual(2)
        expect(newsInstance.results.Fine.length).toEqual(1)
        expect(newsInstance.results.Error.length).toEqual(0)
      done()
    )

    spyOn(newsInstance, 'handleError').andCallFake(() ->
      expect(newsInstance.handleError)
        .toHaveBeenCalledWith('Error', 'Nock: No match for request GET http://trendspottr.com/indexStream.php?q=Error ', 'request')

      numRequestsProcessed++
      if (numRequestsProcessed == 2)
        expect(Object.keys(newsInstance.results).length).toEqual(2)
        expect(newsInstance.results.Fine.length).toEqual(1)
        expect(newsInstance.results.Error.length).toEqual(0)
      done()
    )
