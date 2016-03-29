module.exports.prepare = (options) ->
    opt =
        configFile   : 'modpack.json'
        min          : false
        dev          : true
        keepComment  : true
        keepConsumed : false
        hash         : ''
        jsStart      : '<script src="'
        jsEnd        : '"></script>'
        cssStart     : '<link rel="stylesheet" href="'
        cssEnd       : '">'
        wrapTemplate : (text) ->
        wrapFuntions : (text) ->

    if options?
        for attr in options
            opt[attr] = options[attr]

    config = JSON.parse fs.readFileSync opt.configFile if not config

    [opt, config]
