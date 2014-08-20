module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compile:
        files:
          'lib/trending-news.js': ['src/trending-news.coffee']
          'lib/config.js': ['src/config.coffee']
    jasmine_node:
      options:
        forceExit: true
        extensions: "coffee"
        coffee: true
        includeStackTrace: true
        captureExceptions: true
      all: ['spec/']
  
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-jasmine-node'
  
  grunt.registerTask 'default', ['coffee', 'jasmine_node']
