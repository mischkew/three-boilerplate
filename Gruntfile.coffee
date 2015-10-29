#global module:false

'use strict'

winston = require './tasks/winston'
linkHooks = require './tasks/linkHooks'

module.exports = (grunt) ->
  # load third-party tasks
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-mocha-test'

  # setup custom tasks
  winston(grunt)
  linkHooks(grunt)

  grunt.initConfig
    browserify:
      development:
        files: [
          'public/js/bundle.js': ['src/index.coffee']
        ]
        options:
          transform: ['coffeeify']
          browserifyOptions:
            debug: true
            extensions: [
              '.js',
              '.jsx',
              '.coffee'
            ]

    copy:
      development:
        files: [
          expand: true,
          cwd: 'build/',
          src: '**/*',
          dest: 'public/js/'
        ]

    clean:
      build: [
        'build'
        'public/js/bundle.js'
      ]

    coffeelint:
      development:
        files:
          src: ['src/**/*.coffee']
        options:
          force: true
          configFile: './coffeelint.json'

    watch:
      development:
        options:
          livereload: true
          spawn: false
        files: [
          'src/**/*'
        ]
        tasks: [
          'build:development'
        ]
      test:
        # options:
          # spawn: false
        files: [
          'src/**/*'
          'test/**/*'
        ]
        tasks: [
          'test'
        ]

    connect:
      development:
        options:
          port: 4000
          base: 'public'
          livereload: true

    winston:
      buildLog:
        options:
          console:
            humanReadableUnhandledException: true
            colorize: true
            level: 'debug'

    mochaTest:
      test:
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
        src: ['test/**/*.coffee']


  grunt.registerTask 'build:development', [
    'coffeelint:development'
    'browserify:development'
    'copy:development'
  ]

  grunt.registerTask 'development', [
    'winston' # setup loggers
    'linkHooks'
    'build:development'
    'connect:development'
    'watch:development'
  ]

  grunt.registerTask 'test', [
    'mochaTest:test'
  ]

  grunt.registerTask 'test:watch', [
    'test',
    'watch:test'
  ]

  grunt.registerTask 'default', [
    'development'
  ]
