'use strict'

winston = require 'winston'

module.exports = (grunt) ->

  grunt.registerMultiTask 'winston', ->
    loggerName = @.target
    options = @.options()

    winston.loggers.add loggerName, options
