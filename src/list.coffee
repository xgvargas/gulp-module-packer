through = require 'through2'
common  = require './common.js'

module.exports.list = (options) ->

    [opt, config] = common.prepare options

    config.available = []

    transform = (file, enc, cb) ->

        found = no

        for block in ['js', 'css']
            for pack of config[block]
                for name in config[block][pack]
                    if name == file.relative
                        found = yes

        config.available.push file.relative unless found

        cb null, file

    past = (cb) ->
        common.saveConfig opt.configFile, config
        cb()

    through.obj(transform, past)
