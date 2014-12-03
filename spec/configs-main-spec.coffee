config = require '../lib/config'
configsMain = require '../lib/configs-main'

describe 'setByUserInput', ->

  it "should set correct config values for runMode='default' and scoreThreshold=100", ->

    configsMain.setByUserInput 'default', 100

    expect(config.RUN_MODE).toBe('default')
    expect(config.SCORE_THRESHOLD).toBe(100)
    expect(config.DISABLE_NOCK).toBe(false)
    expect(config.STORAGE_DIR).toBe('TNStorage')
    expect(config.SEND_NOTIFICATIONS).toBe(false)
    expect(config.LOG_LEVEL_THRESHOLD).toBe('info')

  it "should set correct config values for runMode='debug' and scoreThreshold=100", ->

    configsMain.setByUserInput 'debug', 100

    expect(config.RUN_MODE).toBe('debug')
    expect(config.SCORE_THRESHOLD).toBe(100)
    expect(config.DISABLE_NOCK).toBe(false)
    expect(config.STORAGE_DIR).toBe('TNStorage')
    expect(config.SEND_NOTIFICATIONS).toBe(false)
    expect(config.LOG_LEVEL_THRESHOLD).toBe('debug')

  it "should set correct config values for runMode='trace' and scoreThreshold=30", ->

    configsMain.setByUserInput 'trace', 30

    expect(config.RUN_MODE).toBe('trace')
    expect(config.SCORE_THRESHOLD).toBe(30)
    expect(config.DISABLE_NOCK).toBe(false)
    expect(config.STORAGE_DIR).toBe('TNStorage')
    expect(config.SEND_NOTIFICATIONS).toBe(false)
    expect(config.LOG_LEVEL_THRESHOLD).toBe('trace')

  it "should set correct config values for runMode='prod' and scoreThreshold=1", ->

    configsMain.setByUserInput 'prod', 1

    expect(config.RUN_MODE).toBe('prod')
    expect(config.SCORE_THRESHOLD).toBe(1)
    expect(config.DISABLE_NOCK).toBe(true)
    expect(config.STORAGE_DIR).toBe('/data/tn')
    expect(config.SEND_NOTIFICATIONS).toBe(true)
    expect(config.LOG_LEVEL_THRESHOLD).toBe('info')

  # TODO Add tests for bad/invalid parameters, after I create a check in configs.js for them
  # (even though the way this function is called now, params first pass through
  # validate-arguments, and so bad params cannot happen)
