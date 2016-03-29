through     = require 'through2'
fs          = require 'fs'
buffer      = require('buffer').Buffer
gutil       = require 'gulp-util'
common      = require './common.js'
PluginError = gutil.PluginError

module.exports.template = (options) ->

    [opt, config] = common.prepare options

    opt.wrapTemplate ?= (name, content) ->
        "$templateCache.put('#{name}', '#{content}');"

    opt.wrapFuntions ?= (name, content, standalone) ->
        alone = if standalone then ', []' else ''
        """
        angular.module('#{name}'#{alone}).run(["$templateCache", function($templateCache) {
            #{content}
        }]);'
        """

    templates = {}

    transform = (file, env, cb) ->

        console.log file.relative

        pack = 'aa'

        templates[pack] ?= []

        templates[pack].push opt.wrapTemplate file.relative, file.contents

        cb null, file

    pass = (cb) ->
        console.log templates
        cb()

    through.obj(transform, pass)
