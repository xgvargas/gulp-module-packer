fs          = require 'fs'
yaml        = require 'js-yaml'
gutil       = require 'gulp-util'
PluginError = gutil.PluginError

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
        keepConsumed   : no
        hash           : ''
        jsStart        : '<script src="'
        jsEnd          : '"></script>'
        cssStart       : '<link rel="stylesheet" href="'
        cssEnd         : '">'
        keepUninjected : yes
        keepUnpacked   : no
        wrapOpt        : 
            standalone : no
            minify     : yes

    if options?
        for attr, val of options
            opt[attr] = val

    opt.configFile = 'modpack.yaml' if fileExists 'modpack.yaml' unless opt.configFile?
    opt.configFile = 'modpack.json' if fileExists 'modpack.json' unless opt.configFile?

    config = yaml.safeLoad fs.readFileSync opt.configFile if opt.configFile.slice(-5) == '.yaml'
    config = JSON.parse fs.readFileSync opt.configFile if opt.configFile.slice(-5) == '.json'

    if not config?
        throw new PluginError 'gulp-module-packer', 'Invalid config file.'

    [opt, config]

module.exports.saveConfig = (file, data) ->
    if file.slice(-5) == '.yaml'
        fs.writeFileSync file, yaml.safeDump data,
            indent : 4
            noRefs : true

    if file.slice(-5) == '.json'
        fs.writeFileSync file, JSON.stringify(data, null, 4)
