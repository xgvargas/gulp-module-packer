through     = require 'through2'
fs          = require 'fs'
buffer      = require('buffer').Buffer
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
                    txt += block + opt[block + 'End']
                    inject.push txt

        inject


    transform = (file, env, cb) ->
        cb null, file

    through.obj(transform)






#
# function replaceBlock(text, block, data, opt){
#
#     var regex = new RegExp('([\\s\\S]*?)\n?(<!--\\s*gmp:inject:'+block+'\\s*-->)\\n?([\\s\\S]*?)\\n?(<!--\\s*gmp:end\\s*-->)([\\s\\S]*)', 'i');
#
#     var m = regex.exec(text);
#
#     if(m){
#         var new_text = m[1];
#
#         var indent = '\n';
#
#         var l = new_text.length;
#         while(new_text[--l] == ' '){ indent += ' '; }
#
#         if(opt.keepComment) new_text += m[2];
#         for(var i = 0; i < data.length; i++){
#             new_text += indent + data[i];
#         }
#         if(opt.keepComment) new_text += indent + m[4];
#         new_text += m[5];
#
#         return new_text;
#     }
#
#     return text;
# }
#
# var inject = function(options){
#
#     var opt = prepare(options || {});
#
#     return through.obj(function(file, enc, cb){
#         if(file.isStream()){
#             this.emit('error', new PluginError('gulp-module-packer', 'Streaming not supported.'));
#             cb();
#             return;
#         }
#         if(file.relative in config.inject){
#             var js = defineInject(config.inject[file.relative], 'js', opt);
#             var css = defineInject(config.inject[file.relative], 'css', opt);
#
#             var content = replaceBlock(file.contents, 'css', css, opt);
#             content = replaceBlock(content, 'js', js, opt);
#
#             file.contents = new Buffer(content);
#         }
#
#         cb(null, file);
#     });
# };
