"use strict";

var through     = require('through2');
var fs          = require('fs');
var buffer      = require('buffer').Buffer;
var gutil       = require('gulp-util');
var PluginError = gutil.PluginError;

var config;

function prepare(options){
    var opt = {
        configFile   : 'modpack.json',
        min          : false,
        dev          : true,
        keepComment  : true,
        keepConsumed : false,
        hash         : '',
        jsStart      : '<script src="',
        jsEnd        : '"></script>',
        cssStart     : '<link rel="stylesheet" href="',
        cssEnd       : '">',
    };

    for(var attr in options){
        opt[attr] = options[attr];
    }

    if(!config){
        config = JSON.parse(fs.readFileSync(opt.configFile));
    }

    return opt;
}

function defineInject(dst, target, opt){
    var inject = [];

    if(dst[target]){
        for(var i = 0; i < dst[target].length; i++){
            if(opt.dev){
                var name = dst[target][i];
                inject.push('<!-- ' + name + ' -->');
                for(var j = 0; j < config[target][name].length; j++){
                    if(config[target][name][j][0] != ':' || config[target][name][j][1] != ':'){
                        inject.push(opt[target+'Start'] + config[target][name][j] + opt[target+'End']);
                    }
                }
            }
            else{
                var txt = opt[target+'Start'] + dst[target][i] + opt.hash;
                if(opt.min){
                    txt += '.min';
                }
                txt += '.' + target + opt[target+'End'];

                inject.push(txt);
            }
        }
    }
    return inject;
}


function replaceBlock(text, block, data, opt){

    var regex = new RegExp('([\\s\\S]*?)\n?(<!--\\s*gmp:inject:'+block+'\\s*-->)\\n?([\\s\\S]*?)\\n?(<!--\\s*gmp:end\\s*-->)([\\s\\S]*)', 'i');

    var m = regex.exec(text);

    if(m){
        var new_text = m[1];

        var indent = '\n';

        var l = new_text.length;
        while(new_text[--l] == ' '){ indent += ' '; }

        if(opt.keepComment) new_text += m[2];
        for(var i = 0; i < data.length; i++){
            new_text += indent + data[i];
        }
        if(opt.keepComment) new_text += indent + m[4];
        new_text += m[5];

        return new_text;
    }

    return text;
}

var inject = function(options){

    var opt = prepare(options || {});

    return through.obj(function(file, enc, cb){
        if(file.isStream()){
            this.emit('error', new PluginError('gulp-module-packer', 'Streaming not supported.'));
            cb();
            return;
        }
        if(file.relative in config.inject){
            var js = defineInject(config.inject[file.relative], 'js', opt);
            var css = defineInject(config.inject[file.relative], 'css', opt);

            var content = replaceBlock(file.contents, 'css', css, opt);
            content = replaceBlock(content, 'js', js, opt);

            file.contents = new Buffer(content);
        }

        cb(null, file);
    });
};

var concat = function(options){

    var opt = prepare(options || {});

    if(typeof opt.target != 'string'){
        throw new PluginError('gulp-module-packer', 'Missing target in configuration.');
    }
    if(opt.target != 'js' && opt.target != 'css'){
        throw new PluginError('gulp-module-packer', 'Invalid target.');
    }

    var waitFor = {};

    for(var name in config[opt.target]){
        for(var i = 0; i < config[opt.target][name].length; i++) {
            if(config[opt.target][name][i][0] == ':' && config[opt.target][name][i][1] == ':'){
                waitFor[config[opt.target][name][i]] = null;
            }
        }
    }

    var pass = through.obj(function(file, enc, cb){

        var name = '::' + file.relative;

        if(name in waitFor){
            waitFor[name] = file.contents;
            if(!opt.keepConsumed){
                return cb();
            }
        }

        cb(null, file);
    }, function(cb){
        for(var name in config[opt.target]){

            var content = '';

            for(var i = 0; i < config[opt.target][name].length; i++) {

                var file = config[opt.target][name][i];
                if(file[0] == ':' && file[1] == ':'){
                    content += waitFor[file] + '\n';
                }
                else{
                    content += fs.readFileSync(file) + "\n";
                }
            }

            var new_file = new gutil.File({
                cwd      : "",
                base     : "",
                path     : name + '.' + opt.target,
                contents : new Buffer(content)
            });

            pass.write(new_file);
        }
        cb();
    });

    return pass;
};

var list = function(options){

    var opt = prepare(options || {});

    config.available = [];

    return through.obj(function(file, enc, cb){

        var filename = file.relative;
        var found = false;

        for(var name in config[opt.target]){
            for(var i = 0; i < config[opt.target][name].length && !found; i++) {
                if(config[opt.target][name][i] == filename){
                    found = true;
                }
            }
        }

        if(!found){
            config.available.push(filename);
        }

        cb(null, file);
    }, function(cb){

        fs.writeFileSync(opt.configFile, JSON.stringify(config, null, 4));

        cb();
    });
};

module.exports.inject = inject;
module.exports.concat = concat;
module.exports.list = list;
