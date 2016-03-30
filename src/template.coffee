through        = require 'through2'
buffer         = require('buffer').Buffer
gutil          = require 'gulp-util'
common         = require './common.js'
path           = require 'path'
jsStringEscape = require 'js-string-escape'
minify         = require('html-minifier').minify
# miniHTML       = require "mini-html"
# htmlminify     = require 'html-minify'

module.exports.template = (options) ->

    [opt, config] = common.prepare options

    opt.wrapTemplate ?= (name, content) ->
        "$templateCache.put('#{name}', '#{content}');"

    opt.wrapFuntions ?= (name, content, standalone) ->
        alone = if standalone then ', []' else ''
        """
        angular.module('#{name}'#{alone}).run(["$templateCache", function($templateCache) { #{content}
        }]);'
        """

    templates = {}

    transform = (file, env, cb) ->
        filename = file.relative.replace '\\', '/'
        pack = path.dirname filename

        if pack != '.'
            templates[pack] ?= ''
            content = jsStringEscape if opt.minify then minify file.contents, opt.minifyOpt else file.contents
            templates[pack] += '\n    ' + opt.wrapTemplate filename, content
            return cb() unless opt.keepConsumed
        else
            return cb() unless opt.keepUnpacked

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
