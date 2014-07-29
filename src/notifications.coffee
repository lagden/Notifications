###
notification.js - Notifications

It is a plugin that show notification like Growl

@author      Thiago Lagden <lagden [at] gmail.com>
@copyright   Author

Depends:
TweenMax.js
###

((root, factory) ->
  if typeof define is "function" and define.amd
    define ['greensock/TweenMax'], factory
  else
    root.Notifications = factory(root.TweenMax)
  return
) @, (TM) ->

  'use strict'

  wn = window.navigator
  hasPointerEvents = Boolean wn.pointerEnabled or wn.msPointerEnabled
  hasTouchEvents = 'ontouchstart' in window
  isTouch = hasTouchEvents or hasPointerEvents
  eventType = if isTouch then 'touchend' else 'click'

  _privados =
      getTemplate: () ->
        [
          '<h3 class="theNotification__title">{title}</h3>'
          '<p class="theNotification__msg">{msg}</p>'
        ].join ''

      extend: () ->
        out = out or {}
        for args in arguments
          if args is false
            continue
          out[key] = args[key] for key of args when args.hasOwnProperty key
        return out

      remove: (item, ev) ->
        @remove item
        return

      selfRemove: (item) ->
        setTimeout (()->
          @remove item
        ).bind(@), @opts.duration
        return

  options =
    duration: 5000
    container: null
    offset: 10

  class Notifications
    constructor: (opts) ->
      if false is (@ instanceof Notifications)
        return new Notifications(opts)
      @opts = _privados.extend {}, options, opts
      @items = []
      @container = @opts.container or document.body
      @template = @opts.template or _privados.getTemplate()
      return

    notifica: (t, m) ->
      r =
        title: t
        msg: m
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
      item.addEventListener eventType, _privados.remove.bind(@, item), false

      @items.push item
      @render item, offset
      return

    render: (item, offset) ->
      @container.appendChild item

      from =
        y: offset[0]
        opacity: 0

      to =
        y: offset[1],
        opacity: 1,
        onComplete: _privados.selfRemove.bind(@, item)

      TM.fromTo item, 0.5, from, to
      return

    remove: (item) ->
      item.removeEventListener eventType, _privados.remove

      index = @items.indexOf item
      @items.splice index, 1 if index isnt -1

      onCompleteRemove = (() ->
        @container.removeChild(item)
        return
      ).bind @


      to =
        y: '-=30',
        opacity: 0,
        onComplete: onCompleteRemove

      TM.to item, 0.3, to
      return

  return Notifications
