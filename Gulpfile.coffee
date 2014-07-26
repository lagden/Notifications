'use strict'

gulp        = require 'gulp'
sass        = require 'gulp-ruby-sass'
prefix      = require 'gulp-autoprefixer'
jade        = require 'gulp-jade'
coffee      = require 'gulp-coffee'
coffeelint  = require 'gulp-coffeelint'
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

map =
  sass:
    src: 'src/*.sass'
    dest: 'dist/'
  coffee:
    src: 'src/*.coffee'
    dest: 'dist/'
  uglify:
    src: 'dist/notifications.js'
    min: 'notifications.min.js'
    dest: 'dist/'
  pkg:
    src: [
      'dist/{,*/}/gsap/src/uncompressed/TweenMax.js'
      'dist/notifications.js'
    ]
    min: 'notifications.pkg.min.js'
    dest: 'dist/'
  jade:
    src: 'src/*.jade'
    dest: 'examples/'

console.log map.pkg.src

gulp.task 'sass', ->
  gulp.src map.sass.src
    .pipe sass
      trace         : true
      sourcemap     : true
      sourcemapPath : '../dist'
      style         : 'compressed'
      noCache       : true
    .pipe prefix AUTOPREFIXER_BROWSERS
    .pipe gulp.dest map.sass.dest
    .pipe filter '*.css'
    .pipe reload stream: true

gulp.task 'lint', ->
  gulp.src map.coffee.src
    .pipe coffeelint()
    .pipe coffeelint.reporter()

gulp.task 'coffee', ->
  gulp.src map.coffee.src
    .pipe coffee(bare: true).on 'error', util.log
    .pipe gulp.dest map.coffee.dest
    .pipe reload stream: true

gulp.task 'uglify', ->
  gulp.src map.uglify.src
    .pipe uglify map.uglify.min, outSourceMap: true
    .pipe gulp.dest map.uglify.dest

gulp.task 'pkg', ->
  gulp.src map.pkg.src, base: map.pkg.dest
    .pipe uglify map.pkg.min, outSourceMap: true
    .pipe gulp.dest map.pkg.dest

gulp.task 'jade', ->
  gulp.src map.jade.src
    .pipe jade pretty: true
    .pipe gulp.dest map.jade.dest
    .pipe reload stream: true

gulp.task 'watch', ->
  gulp.watch map.sass.src, ['sass']
  gulp.watch map.coffee.src, ['lint', 'coffee', 'uglify', 'pkg']
  gulp.watch map.jade.src, ['jade']
  return

gulp.task 'server', ['default', 'watch'], ->
  browserSync
    notify: false
    port: 8182
    server:
      baseDir: ['examples', 'dist']
  return

gulp.task 'default', ['sass', 'jade', 'lint', 'coffee', 'uglify', 'pkg']
