through     = require 'through2'
fs          = require 'fs'
buffer      = require('buffer').Buffer
gutil       = require 'gulp-util'
common      = require './common.js'
PluginError = gutil.PluginError

module.exports.concat = (options) ->

    [opt, config] = common.prepare options

    throw new PluginError 'gulp-module-packer', 'Missing target in configuration.'  if typeof opt.target != 'string'

    if opt.target != 'js' and opt.target != 'css'
        throw new PluginError 'gulp-module-packer', 'Invalid target.'

    waitFor = {}

    for pack in config[opt.target]
        for name in pack
            if name[0] == ':' and name[1] == ':'
                waitFor[name] = null

    transform = (file, env, cb) ->
        name = '::' + file.relative

        if name in waitFor
            waitFor[name] = file.contents
            return cb() if not opt.keepConsumed

        cb(null, file)

    stream = through.obj(transform, past)

    pass = (cb) ->

        for pack in config[opt.target]

            content = ''

            for file in pack
                if file[0] == ':' and file[1] == ':'
                    content += waitFor[file] + '\n'
                else
                    content += fs.readFileSync(file) + "\n"

            new_file = new gutil.File
                cwd      : ""
                base     : ""
                path     : pack + '.' + opt.target
                contents : new Buffer content

            stream.write new_file
        cb()

    stream
