'use strict'

fs = require 'fs'
path = require 'path'
winston = require 'winston'


module.exports = (grunt) ->

  grunt.registerTask 'linkHooks', ->
    buildLog = winston.loggers.get 'buildLog'

    # The first 9 hooks are taken from `git init` which creates .sample files
    # even though some of them are not listed in the
    # [documentation](http://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).
    # The rest of the hooks are taken from the documentation.
    [
      'applypatch-msg'
      'commit-msg'
      'post-commit'
      'post-receive'
      'post-update'
      'pre-applypatch'
      'pre-commit'
      'prepare-commit-msg'
      'pre-rebase'
      'update'
      'post-rewrite'
      'post-checkout'
      'post-merge'
      'pre-push'
      'pre-auto-gc'
    ]
    .forEach (hook) ->
      hookPath = path.join('hooks', hook)
      gitHookPath = path.join('.git/hooks', hook)

      fs.unlink gitHookPath, (error) ->
        if error and error.code is not 'ENOENT'
          buildLog.error error

        fs.link hookPath, gitHookPath, (error) ->
          if error
            if error.code is not 'ENOENT'
              buildLog.error error
          else
            buildLog.info hookPath, '->', gitHookPath
