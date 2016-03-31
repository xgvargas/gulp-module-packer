through     = require 'through2'
fs          = require 'fs'
gutil       = require 'gulp-util'
common      = require './common.js'
path        = require 'path'
stream      = require 'stream'
PluginError = gutil.PluginError

module.exports.concat = (options) ->

    [opt, config] = common.prepare options

    throw new PluginError 'gulp-module-packer', 'Missing `block` in options.'  if typeof opt.block != 'string'
    throw new PluginError 'gulp-module-packer', 'Invalid block.' if opt.block != 'js' and opt.block != 'css'

    waitFor = {}

    pushFiles = (obj) ->
        for pack of config[opt.block]

            content = opt.header

            for file in config[opt.block][pack]
                if file[0] == ':' and file[1] == ':'
                    content += waitFor[file] + '\n'
                else
                    content += fs.readFileSync(path.join opt.base, file) + "\n"

            min = if opt.min then '.min' else ''

            obj.push new gutil.File
                cwd      : ""
                base     : ""
                path     : "#{pack}#{opt.hash}#{min}.#{opt.block}"
                contents : new Buffer content
        return

    if opt.mode == 'pipe'
        for pack of config[opt.block]
            for name in config[opt.block][pack]
                if name[0] == ':' and name[1] == ':'
                    waitFor[name] = "/* === Oops! Can't find `#{name}` in stream... === */"

        transform = (file, env, cb) ->
            if file.isStream()
                @emit 'error', new PluginError 'gulp-module-packer', 'Streaming not supported.'
                return cb()

            name = '::' + file.relative.replace /\\/g, '/'

            if name of waitFor
                waitFor[name] = file.contents
                return cb() if not opt.keepConsumed

            cb(null, file)

        past = (cb) ->
            pushFiles @
            cb()

        return through.obj transform, past

    if opt.mode == 'src'
        stream = new stream.Readable
            objectMode    : true
            highWaterMark : 16

        stream._read = (chunk) ->
            pushFiles @
            @push null

        return stream
