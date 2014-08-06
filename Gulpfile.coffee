'use strict'

gulp        = require 'gulp'
prefix      = require 'gulp-autoprefixer'
coffee      = require 'gulp-coffee'
coffeelint  = require 'gulp-coffeelint'
concat      = require 'gulp-concat'
filter      = require 'gulp-filter'
jade        = require 'gulp-jade'
sass        = require 'gulp-ruby-sass'
uglify      = require 'gulp-uglifyjs'
util        = require 'gulp-util'

del         = require 'del'
runSequence = require 'run-sequence'

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
  jade:
    src: 'src/*.jade'
    dest: 'examples/'

  sass:
    src: 'src/*.sass'
    dest: 'dist/'

  clean:
    src: 'dist/{*.css,*.js,*.map}'

  coffee:
    src: 'src/*.coffee'
    dest: 'dist/'

  pkg:
    src: [
      'dist/lib/gsap/src/uncompressed/TweenMax.js'
      'dist/notifications.js'
    ]
    out: 'notifications.pkg.js'
    dest: 'dist/'

  uglify:
    src:
      file: 'dist/notifications.js'
      pkg: 'dist/notifications.pkg.js'
    out:
      file: 'notifications.min.js'
      pkg: 'notifications.pkg.min.js'
    dest: 'dist/'

gulp.task 'jade', ->
  gulp.src map.jade.src
    .pipe jade pretty: true
    .pipe gulp.dest map.jade.dest
    .pipe reload stream: true

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

gulp.task 'pkg', ->
  gulp.src map.pkg.src
    .pipe concat map.pkg.out
    .pipe gulp.dest map.pkg.dest
    .pipe reload stream: true

gulp.task 'uglify', ->
  gulp.src map.uglify.src.file
    .pipe uglify map.uglify.out.file, outSourceMap: true
    .pipe gulp.dest map.uglify.dest

  gulp.src map.uglify.src.pkg
    .pipe uglify map.uglify.out.pkg, outSourceMap: true
    .pipe gulp.dest map.uglify.dest

  return

gulp.task 'watch', ->
  gulp.watch [map.sass.src], ['sass']
  gulp.watch [map.coffee.src], ['scripts']
  gulp.watch [map.jade.src], ['jade']
  return

gulp.task 'clean', del.bind null, map.clean.src

gulp.task 'scripts', ->
  runSequence 'lint', 'coffee', 'pkg'
  return

gulp.task 'default', ->
  runSequence 'clean', ['jade', 'sass', 'scripts'], 'uglify'
  return

gulp.task 'server', ->
  runSequence 'default', 'watch'
  return

gulp.task 'start', ['server'], ->
  browserSync
    notify: true
    port: 8182
    server:
      baseDir: ['examples', 'dist']
  return