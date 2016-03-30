through     = require 'through2'
fs          = require 'fs'
gutil       = require 'gulp-util'
common      = require './common.js'
PluginError = gutil.PluginError

module.exports.inject = (options) ->

    [opt, config] = common.prepare options

    defineInjection = (target, block) ->
        inject = []

        if config.inject[target][block]
            for pack in config.inject[target][block]
                if opt.dev
                    inject.push "<!-- #{pack} -->"
                    for file in config[block][pack]
                        if file[0] != ':' or file[1] != ':'
                            inject.push opt[block + 'Start'] + file + opt[block + 'End']
                else
                    txt = opt[block + 'Start'] + pack + opt.hash
                    txt += '.min' if opt.min
                    txt += '.' + block + opt[block + 'End']
                    inject.push txt

        inject

    replaceBlock = (text, block, data) ->

        if block == 'js'
            regex = ///
                ([\s\S]*?)   # 1
                \n?
                (<!--\s*gmp:inject:js\s*-->)  # 2
                \n?
                ([\s\S]*?)   # 3
                \n?
                (<!--\s*gmp:end\s*-->)  # 4
                ([\s\S]*)   # 5
                ///i
        else
            regex = ///
                ([\s\S]*?)   # 1
                \n?
                (<!--\s*gmp:inject:css\s*-->)  # 2
                \n?
                ([\s\S]*?)   # 3
                \n?
                (<!--\s*gmp:end\s*-->)  # 4
                ([\s\S]*)   # 5
                ///i

        m = regex.exec text

        if m
            new_text = m[1]

            l = new_text.length
            indent = '\n'
            while new_text[--l] == ' '
                indent += ' '

            new_text += m[2] if opt.keepComment
            for item in data
                new_text += indent + item

            new_text += indent + m[4] if opt.keepComment

            new_text += m[5]

            return new_text

        text

    transform = (file, env, cb) ->
        if file.isStream()
            @emit 'error', new PluginError 'gulp-module-packer', 'Streaming not supported.'
            return cb()

        filename = file.relative.replace '\\', '/'

        if config.inject[filename]?
            content = replaceBlock file.contents, 'css', defineInjection filename, 'css'
            content = replaceBlock content, 'js', defineInjection filename, 'js'

            file.contents = new Buffer content
        else
            return cb() unless opt.keepUninjected

        cb null, file

    through.obj transform
