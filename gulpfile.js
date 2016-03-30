var gulp = require('gulp');
var packer = require('./index.js');

gulp.task('list', function(){
    return gulp.src(['www/**/*.js', 'www/**/*.css'], {read: false, base: 'www'})
        .pipe(packer.list());
});

gulp.task('list-json', function(){
    return gulp.src(['www/**/*.js', 'www/**/*.css'], {read: false, base: 'www'})
        .pipe(packer.list({
            configFile: 'modpack.json'
        }));
});

gulp.task('inject1', function(){
    return gulp.src('www/**/*.html')
        .pipe(packer.inject({
            dev  : false,
            hash : '.12345'
        }))
        .pipe(gulp.dest('dist'));
});

gulp.task('inject2', function(){
    return gulp.src('www/**/*.html')
        .pipe(packer.inject({
            dev  : false,
            hash : '.12345',
            min  : true
        }))
        .pipe(gulp.dest('dist'));
});

gulp.task('inject3', function(){
    return gulp.src('www/**/*.html')
        .pipe(packer.inject({}))
        .pipe(gulp.dest('dist'));
});

gulp.task('inject4', function(){
    return gulp.src('www/**/*.html')
        .pipe(packer.inject({
            dev         : false,
            min         : true,
            keepComment : false,
        }))
        .pipe(gulp.dest('dist'));
});

gulp.task('concat', function(){
    return gulp.src('')
        .pipe(packer.concat({
            block: 'js',
            hash: '.123123',
            min: 'true'
        }))
        .pipe(gulp.dest('dist'));
});

gulp.task('template', function(){
    return gulp.src('www/**/*.html')
        .pipe(packer.template({}))
        .pipe(gulp.dest('dist'));
});

gulp.task('concat2', function(){
    return gulp.src('www/**/*.html')
        .pipe(packer.template({}))
        .pipe(packer.concat({
            block: 'js'
        }))
        .pipe(gulp.dest('dist'));
});
