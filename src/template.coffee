through        = require 'through2'
buffer         = require('buffer').Buffer
gutil          = require 'gulp-util'
common         = require './common.js'
path           = require 'path'
jsStringEscape = require 'js-string-escape'

module.exports.template = (options) ->

    [opt, config] = common.prepare options

    opt.wrapTemplate ?= (name, content) ->
        "$templateCache.put('#{name}', '#{jsStringEscape(content)}');"

    opt.wrapFuntions ?= (name, content, standalone) ->
        alone = if standalone then ', []' else ''
        """
        angular.module('#{name}'#{alone}).run(["$templateCache", function($templateCache) { #{content}
        }]);'
        """

    templates = {}

    transform = (file, env, cb) ->

        pack = path.dirname file.relative

        if pack != '.'
            templates[pack] ?= ''
            templates[pack] += '\n    ' + opt.wrapTemplate file.relative, file.contents
            return cb() if not opt.keepConsumed

        cb null, file

    past = (cb) ->
        for pack of templates
            new_file = new gutil.File
                cwd      : ""
                base     : ""
                path     : "#{pack}.js"
                contents : new Buffer opt.wrapFuntions pack, templates[pack], opt.standalone

            stream.write new_file
        cb()

    stream = through.obj(transform, past)
