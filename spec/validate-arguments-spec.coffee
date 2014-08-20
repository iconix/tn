validateArguments = require('../lib/validate-arguments')

describe "validateArguments", ->

  it 'should ensure that the first arg is a valid string, and the second arg is a number 1..100 inclusive', ->
    # NOTE: parameters of validateArguments(...) come from command-line arguments,
    #       and command-line arguments are strings!

    expect(validateArguments()).toBe(true)
    
    expect(validateArguments('100')).toBe(true)
    expect(validateArguments('50')).toBe(true)
    expect(validateArguments('0')).toBe(false)
    expect(validateArguments('-1')).toBe(false)
    expect(validateArguments('101')).toBe(false)

    expect(validateArguments('prod')).toBe(true)
    expect(validateArguments('')).toBe(true)
    expect(validateArguments('  ')).toBe(false)
    expect(validateArguments('what?')).toBe(false)

    expect(validateArguments('debug', '42')).toBe(true)
    expect(validateArguments('42', 'debug')).toBe(false)
    expect(validateArguments('', '0')).toBe(false)
    expect(validateArguments('what?', '99')).toBe(false)
    expect(validateArguments('test', '-1')).toBe(false)
    expect(validateArguments('test', 'ok')).toBe(false)
    expect(validateArguments('1', '100')).toBe(false)
