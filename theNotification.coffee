###
theNotification.js - Notifications

It is a plugin that show notification like Growl

@author      Thiago Lagden <lagden [at] gmail.com>
@copyright   Author
###

((root, factory) ->
  if typeof define is "function" and define.amd
    define factory
  else
    root.TheNotification = factory()
  return
) @, () ->

  'use strict'

  getTemplate = ->
    [
      '<h3 class="theNotification__title">{title}</h3>'
      '<p class="theNotification__msg">{msg}</p>'
    ].join ''

  extend = ->
    out = out or {}
    for args in arguments
      if args is false
        continue
      out[key] = args[key] for key of args when args.hasOwnProperty key
    out

  animate = (opts) ->
    start = new Date().getTime()

    run = ->
      timePassed = new Date().getTime() - start
      progress = timePassed / opts.duration
      progress = 1 if progress > 1
      delta = opts.delta progress
      opts.step delta

      if progress == 1
        opts.complete()
      else
        requestAnimationFrame(run)
      return

    requestAnimationFrame(run)
    return

  handlerRemove = (item, ev) ->
    @remove item
    return

  options = {
      duration: 5000
      container: null
      offset: 10
  }

  class TheNotification
    constructor: (opts) ->
      return new TheNotification(opts) if false is (@ instanceof TheNotification)
      @opts = extend {}, options, opts
      @items = []
      @container = @opts.container or document.body
      @template = @opts.template or getTemplate()
      return

    notifica = (t, m) ->
      r = {
        title: t
        msg: m
      }
      content = @template.replace /\{(.*?)\}/g, (a, b) ->
        return r[b]
  
      item = document.createElement 'div'
      item.className = 'theNotification'
      item.style.opacity = 0
      item.insertAdjacentHTML 'afterbegin', content
  
      offset = [
        0
        @opts.offset
      ]
      last = @items[@items.length - 1]
      if last
        offset[0] = parseInt last.getAttribute('data-offset'), 10
        offset[1] = parseInt (offset[0] + last.offsetHeight + @opts.offset), 10
  
      item.setAttribute 'data-offset', offset[1]
      item.addEventListener 'click', handlerRemove.bind(@, item), false
  
      @opts.push item
      @render item, offset
      return

    render = (item, offset) ->
      @container.appendChild item
      
      item.style.top = offset[0]
      item.style.opacity = 0
      
      from = offset[0]
      to = offset[1]
  
      animate {
        duration: 500
        delta: (p) ->
          return 1 - Math.sin Math.acos p
        step: (d) ->
          t = parseInt((d * (to-from)) + from, 10)
          item.style.top = t + 'px'
          item.style.opacity = d
          return
        complete: (->
          setTimeout (->
            @remove item
            return
          ).bind(@), @opts.duration
          return
        ).bind @
      }
      return

    remove = (item) ->
      index = @items.indexOf item
      item.removeEventListener 'click', handlerRemove
      return @ if index is -1
      @items.splice index, 1
      from = parseInt item.style.top, 10
      to = from - 30
      animate {
        duration: 300
        delta: (p) ->
          return 1 - Math.sin Math.acos p
        step: (d) ->
          t = parseInt((d * (to-from)) + from, 10)
          o = (d * (0-1)) + 1;
          item.style.top = t + 'px'
          item.style.opacity = o
          return
        complete: (->
          that.container.removeChild item
          return
        ).bind @
      }
      return

  return TheNotification
