'use strict';
var AUTOPREFIXER_BROWSERS, browserSync, coffee, filter, gulp, jade, prefix, reload, sass, uglify, util;

gulp = require('gulp');

sass = require('gulp-ruby-sass');

prefix = require('gulp-autoprefixer');

jade = require('gulp-jade');

coffee = require('gulp-coffee');

uglify = require('gulp-uglifyjs');

filter = require('gulp-filter');

util = require('gulp-util');

browserSync = require('browser-sync');

reload = browserSync.reload;

AUTOPREFIXER_BROWSERS = ['ie >= 10', 'ie_mob >= 10', 'ff >= 30', 'chrome >= 34', 'safari >= 7', 'opera >= 23', 'ios >= 7', 'android >= 4.4', 'bb >= 10'];

gulp.task('css', function() {
  gulp.src('*.sass').pipe(sass({
    trace: true,
    sourcemap: true,
    sourcemapPath: './',
    style: 'compressed',
    noCache: true
  })).pipe(prefix(AUTOPREFIXER_BROWSERS)).pipe(gulp.dest('dist/')).pipe(filter('*.css')).pipe(reload({
    stream: true
  }));
});

gulp.task('html', function() {
  gulp.src('examples/*.jade').pipe(jade({
    pretty: true
  })).pipe(gulp.dest('examples/')).pipe(reload({
    stream: true
  }));
});

gulp.task('coffee', function() {
  gulp.src('*.coffee').pipe(coffee({
    bare: true
  }).on('error', util.log)).pipe(gulp.dest('dist/')).pipe(reload({
    stream: true
  }));
});

gulp.task('uglify', function() {
  gulp.src('dist/the-notification.js').pipe(uglify('the-notification.min.js', {
    outSourceMap: true
  })).pipe(gulp.dest('dist/'));
});

gulp.task('watch', function() {
  gulp.watch('*.sass', ['css']);
  gulp.watch('examples/*.jade', ['html']);
  gulp.watch('*.coffee', ['coffee', 'uglify']);
});

gulp.task('server', ['default', 'watch'], function() {
  browserSync({
    notify: false,
    port: 8182,
    server: {
      baseDir: ['examples', 'dist']
    }
  });
});

gulp.task('default', ['css', 'html', 'coffee', 'uglify']);
