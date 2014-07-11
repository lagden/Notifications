gulp = require 'gulp'
sass = require 'gulp-ruby-sass'
prefix = require 'gulp-autoprefixer'
jade = require 'gulp-jade'
coffee = require 'gulp-coffee'
connect = require 'gulp-connect'
util = require 'gulp-util'


gulp.task 'css', ->
  gulp.src 'theNotification.sass'
    .pipe sass {
      sourcemap: true
      sourcemapPath: './'
    }
    .pipe prefix "> 1%"
    .pipe gulp.dest 'dist/'

gulp.task 'html', ->
  gulp.src 'example/*.jade'
    .pipe jade {
        pretty: true
      }
    .pipe gulp.dest 'example/'

gulp.task 'coffee', ->
  gulp.src 'theNotification.coffee'
    .pipe coffee(bare: true).on 'error', util.log
    .pipe gulp.dest 'dist/'

gulp.task 'watch', ->
  gulp.watch 'theNotification.sass', ['css']
  gulp.watch 'example/*.jade', ['html']
  gulp.watch 'theNotification.coffee', ['coffee']

gulp.task 'connectDist', ->
  connect.server {
    root: './'
    port: 8001
    livereload: true
  }

gulp.task 'default', ['css', 'html', 'coffee', 'connectDist', 'watch']
