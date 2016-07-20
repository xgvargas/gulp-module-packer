fs            = require 'fs'
yaml          = require 'js-yaml'
{PluginError} = require 'gulp-util'

# String::startsWith ?= (s) -> @slice(0, s.length) == s
# String::endsWith   ?= (s) -> s == '' or @slice(-s.length) == s

fileExists = (path) ->
    try
        return fs.statSync(path).isFile()
    catch error
        return false

module.exports.prepare = (options) ->
    opt =
        configFile     : null
        base           : 'www/'
        min            : no
        dev            : yes
        keepComment    : yes
        header         : ''
        mode           : 'pipe'
        keepConsumed   : no
        hash           : ''
        jsStart        : '<script src="'
        jsEnd          : '"></script>'
        cssStart       : '<link rel="stylesheet" href="'
        cssEnd         : '">'
        keepUninjected : yes
        keepUnpacked   : no
        wrapOpt        :
            standalone : yes
            minify     : yes

    if options?
        opt[k] = val for k, val of options

    opt.configFile ?= 'modpack.yaml' if fileExists 'modpack.yaml'
    opt.configFile ?= 'modpack.json' if fileExists 'modpack.json'

    config = yaml.safeLoad fs.readFileSync opt.configFile if opt.configFile[-5..] == '.yaml'
    config = JSON.parse fs.readFileSync opt.configFile if opt.configFile[-5..] == '.json'

    unless config?
        throw new PluginError 'gulp-module-packer', 'Invalid config file.'

    [opt, config]

module.exports.saveConfig = (file, data) ->
    if file[-5..] == '.yaml'
        fs.writeFileSync file, yaml.safeDump data,
            indent : 4
            noRefs : true

    if file[-5..] == '.json'
        fs.writeFileSync file, JSON.stringify data, null, 4


module.exports.getConfig = (name) ->
    [opt, cfg] = module.exports.prepare()

    for n in name.split '.'
        cfg = if cfg?[n]? then cfg[n] else null

    cfg
