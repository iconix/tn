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
    jsdoc:
      dist:
        src: ['index.js', 'lib', 'README.md']
        options:
          configure: './node_modules/grunt-jsdoc/node_modules/jsdoc/conf.json'
          private: false
  
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-jasmine-node'
  grunt.loadNpmTasks 'grunt-jsdoc'
  
  grunt.registerTask 'default', ['coffee', 'jasmine_node', 'jsdoc']
