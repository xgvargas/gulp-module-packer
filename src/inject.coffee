through     = require 'through2'
fs          = require 'fs'
buffer      = require('buffer').Buffer
gutil       = require 'gulp-util'
common      = require './common.js'
PluginError = gutil.PluginError

module.exports.inject = (options) ->

    [opt, config] = common.prepare options

    transform = (file, env, cb) ->
        cb null, file

    through.obj(transform)
