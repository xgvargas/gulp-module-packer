through = require 'through2'
common  = require './common.js'

module.exports.list = (options) ->

    [opt, config] = common.prepare options

    config.available = []

    transform = (file, enc, cb) ->

        found = no

        for pack in config.js
            for name in pack
                if name == file.relative
                    found = yes

        for pack in config.css
            for name in pack
                if name == file.relative
                    found = yes

        config.available.push file.relative unless found

        cb null, file

    past = (cb) ->
        fs.writeFileSync opt.configFile, JSON.stringify(config, null, 4)
        cb()

    through.obj(transform, past)
