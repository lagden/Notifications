'use strict'

gulp        = require 'gulp'
sass        = require 'gulp-ruby-sass'
prefix      = require 'gulp-autoprefixer'
jade        = require 'gulp-jade'
coffee      = require 'gulp-coffee'
uglify      = require 'gulp-uglifyjs'
filter      = require 'gulp-filter'
util        = require 'gulp-util'

browserSync = require 'browser-sync'
reload      = browserSync.reload

AUTOPREFIXER_BROWSERS = [
  'ie >= 10'
  'ie_mob >= 10'
  'ff >= 30'
  'chrome >= 34'
  'safari >= 7'
  'opera >= 23'
  'ios >= 7'
  'android >= 4.4'
  'bb >= 10'
]

gulp.task 'css', ->
  gulp.src '*.sass'
    .pipe sass {
      sourcemap: true
      sourcemapPath: './'
    }
    .pipe prefix AUTOPREFIXER_BROWSERS
    .pipe gulp.dest 'dist/'
    .pipe filter '*.css'
    .pipe reload {stream: true}
  return

gulp.task 'html', ->
  gulp.src 'examples/*.jade'
    .pipe jade {
        pretty: true
      }
    .pipe gulp.dest 'examples/'
    .pipe reload {stream: true}
  return

gulp.task 'coffee', ->
  gulp.src '*.coffee'
    .pipe coffee(bare: true).on 'error', util.log
    .pipe gulp.dest 'dist/'
    .pipe reload {stream: true}
  return

gulp.task 'uglify', ->
  gulp.src 'dist/the-notification.js'
    .pipe uglify 'the-notification.min.js',
      outSourceMap: true
    .pipe gulp.dest 'dist/'
  return

gulp.task 'watch', ->
  gulp.watch '*.sass', ['css']
  gulp.watch 'examples/*.jade', ['html']
  gulp.watch '*.coffee', ['coffee', 'uglify']
  return

gulp.task 'server', ['default', 'watch'], ->
  browserSync {
    notify: false
    port: 8182
    server: {
      baseDir: ['examples', 'dist']
    }
  }
  return

gulp.task 'default', ['css', 'html', 'coffee', 'uglify']
