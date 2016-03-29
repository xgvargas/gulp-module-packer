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

gulp.task('inject', function(){
    return gulp.src('www/**/*.html')
        .pipe(packer.inject({}))
        .pipe(gulp.dest('dist'));
});

gulp.task('concat', function(){
    return gulp.src('')
        .pipe(packer.concat({
            target: 'js'
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
            target: 'js'
        }))
        .pipe(gulp.dest('dist'));
});
