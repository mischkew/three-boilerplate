#global module:false

'use strict'

module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-browserify'

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

    watch:
      options:
        livereload: true
      development:
        files: [
          'src/**/*'
        ]
        tasks: [
          'build:development'
        ]

    connect:
      development:
        options:
          port: 4000
          base: 'public'
          livereload: true


  grunt.registerTask 'build:development', [
    'browserify:development'
    'copy:development'
  ]

  grunt.registerTask 'development', [
    'build:development'
    'connect:development'
    'watch:development'
  ]

  grunt.registerTask 'default', [
    'development'
  ]
