fs          = require 'fs'
yaml        = require 'js-yaml'
gutil       = require 'gulp-util'
PluginError = gutil.PluginError

# String::startsWith ?= (s) -> @slice(0, s.length) == s
# String::endsWith   ?= (s) -> s == '' or @slice(-s.length) == s

module.exports.prepare = (options) ->
    opt =
        configFile   : 'modpack.yaml'
        base         : 'www/'
        min          : no
        dev          : yes
        keepComment  : yes
        keepConsumed : no
        hash         : ''
        jsStart      : '<script src="'
        jsEnd        : '"></script>'
        cssStart     : '<link rel="stylesheet" href="'
        cssEnd       : '">'
        standalone   : no
        minify       : yes
        keepUnpacked : no
        minifyOpt    :
            removeComments       : yes
            collapseWhitespace   : yes
            conservativeCollapse : yes
            preserveLineBreaks   : no

    if options?
        for attr, val of options
            opt[attr] = val

    if opt.configFile.slice(-5) == '.yaml'
        config = yaml.safeLoad fs.readFileSync opt.configFile

    if opt.configFile.slice(-5) == '.json'
        config = JSON.parse fs.readFileSync opt.configFile

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
