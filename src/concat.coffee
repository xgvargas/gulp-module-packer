through     = require 'through2'
fs          = require 'fs'
buffer      = require('buffer').Buffer
gutil       = require 'gulp-util'
common      = require './common.js'
PluginError = gutil.PluginError

module.exports.concat = (options) ->

    [opt, config] = common.prepare options

    throw new PluginError 'gulp-module-packer', 'Missing `block` in options.'  if typeof opt.block != 'string'
    throw new PluginError 'gulp-module-packer', 'Invalid block.' if opt.block != 'js' and opt.block != 'css'

    waitFor = {}

    for pack of config[opt.block]
        for name in config[opt.block][pack]
            if name[0] == ':' and name[1] == ':'
                waitFor[name] = null

    transform = (file, env, cb) ->
        name = '::' + file.relative.replace '\\', '/'

        if name of waitFor
            waitFor[name] = file.contents
            return cb() if not opt.keepConsumed

        cb(null, file)

    past = (cb) ->

        for pack of config[opt.block]

            content = ''

            for file in config[opt.block][pack]
                if file[0] == ':' and file[1] == ':'
                    content += waitFor[file] + '\n'
                else
                    content += fs.readFileSync(opt.base + file) + "\n"

            min = if opt.min then '.min' else ''

            new_file = new gutil.File
                cwd      : ""
                base     : ""
                path     : "#{pack}#{opt.hash}#{min}.#{opt.block}"
                contents : new Buffer content

            stream.write new_file
        cb()

    stream = through.obj(transform, past)
