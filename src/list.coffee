through    = require 'through2'
common     = require './common.js'
{relative} = require 'path'

module.exports.list = (options) ->

    [opt, config] = common.prepare options

    config.available = []

    transform = (file, enc, cb) ->
        found = no
        filename = relative(opt.base, file.relative).replace /\\/g, '/'

        for block in ['js', 'css']
            for pack of config[block]
                for name in config[block][pack]
                    if name == filename
                        found = yes

        config.available.push filename unless found

        cb null, file

    past = (cb) ->
        common.saveConfig opt.configFile, config
        cb()

    through.obj transform, past
