through        = require 'through2'
gutil          = require 'gulp-util'
common         = require './common.js'
path           = require 'path'
jsStringEscape = require 'js-string-escape'

module.exports.template = (options) ->

    [opt, config] = common.prepare options

    opt.wrapTemplate ?= (name, content, opt) ->
        if opt.minify
            content = content.replace /(?:<!--[\s\S]*?-->)|(?:\s*[\n\r]+\s*)/g, ''
            content = content.replace /\s{2,}/g, ' '
            content = content.replace /\s>/g, '>'
            content = content.replace /<\s/g, '<'

        "$templateCache.put('#{name}', '#{jsStringEscape content}');"

    opt.wrapFuntions ?= (name, content, opt) ->
        alone = if opt.standalone then ', []' else ''
        """
        angular.module('#{name}'#{alone}).run(["$templateCache", function($templateCache) { #{content}
        }]);
        """

    templates = {}

    transform = (file, env, cb) ->
        if file.isStream()
            @emit 'error', new PluginError 'gulp-module-packer', 'Streaming not supported.'
            return cb()

        filename = file.relative.replace '\\', '/'
        pack = path.dirname filename

        if pack != '.'
            templates[pack] ?= ''
            templates[pack] += '\n    ' + opt.wrapTemplate filename, file.contents.toString(), opt.wrapOpt
            return cb() unless opt.keepConsumed
        else
            return cb() unless opt.keepUnpacked

        cb null, file

    past = (cb) ->
        for pack of templates
            console.log opt.wrapFuntions pack, templates[pack], opt.wrapOpt
            new_file = new gutil.File
                cwd      : ""
                base     : ""
                path     : "#{pack}.js"
                contents : new Buffer opt.wrapFuntions pack, templates[pack], opt.wrapOpt

            @push new_file
        cb()

    through.obj transform, past
