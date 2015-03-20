###
notification.js - Notifications

It is a plugin that show notification like Growl

@author      Thiago Lagden <lagden [at] gmail.com>
@copyright   Author
###

((root, factory) ->
  if typeof define is 'function' and define.amd
    define [
        'TweenMax'
        'tap'
      ], factory
  else
    root.Notifications = factory root.TweenMax,
                                 root.Tap
  return
) @, (TM, Tap) ->

  'use strict'

  extend = (a, b) ->
    a[ prop ] = b[ prop ] for prop of b
    return a

  # Default Options
  options =
    duration: 5000
    container: null
    offset: 10

  # Notifications
  class Notifications
    constructor: (opts) ->
      return new Notifications opts if (@ instanceof Notifications) is false
      @opts = extend options, opts
      @items = []
      @events = {}
      @container = @opts.container or document.body
      @template = @opts.template or @getTemplate()

    # Template
    getTemplate: ->
      [
        '<h3 class="theNotification__title">{title}</h3>'
        '<p class="theNotification__msg">{msg}</p>'
      ].join ''

    # Build
    notifica: (t, m) ->

      # Template
      r =
        title: t
        msg: m

      # Template render
      content = @template.replace /\{(.*?)\}/g, (a, b) ->
        return r[b]

      # Create item
      item = document.createElement 'div'
      item.className = 'theNotification'
      item.style.opacity = 0
      item.insertAdjacentHTML 'afterbegin', content

      # Set initial position
      offset = [0, @opts.offset]

      # Looking for an item to setting the new position
      last = @items[@items.length - 1]
      if last
        offset[0] = parseInt last.getAttribute('data-offset'), 10
        offset[1] = parseInt (offset[0] + last.offsetHeight + @opts.offset), 10

      # Setting attributes
      item.setAttribute 'data-offset', offset[1]

      # Listener
      new Tap item
      item.addEventListener 'tap', @, false

      # Keep item
      @items.push item

      # Put and animate item
      @put item, offset

      # Force Garbage Collection
      item = null
      return

    put: (item, offset) ->
      # Add to DOM
      @container.appendChild item

      selfRemove = (item, duration) ->
        t = setTimeout () ->
          item.dispatchEvent(new Event 'tap')
          item = null
          clearTimeout t
          return
        , duration
        return

      TM.fromTo item, 0.5, {
        y: offset[0]
        opacity: 0
      }, {
        y: offset[1]
        opacity: 1
        onComplete: selfRemove
        onCompleteParams: [item, @opts.duration]
      }

      # Force Garbage Collection
      item = null
      return

    # Animate and remove item
    remove: (event) ->

      event.preventDefault()

      # Getting item
      item = event.currentTarget

      # remove event listener
      item.removeEventListener 'tap', @, false

      # Animation
      onCompleteRemove = (item) =>
        index = @items.indexOf item
        if index isnt -1
          @container.removeChild @items[index]
          @items.splice index, 1
        # Force Garbage Collection
        item = null
        return

      TM.to item, 0.3,
        y: '-=30'
        opacity: 0
        onComplete: onCompleteRemove
        onCompleteParams: [item]

      # Force Garbage Collection
      item = null
      return

    handleEvent: (event) ->
      switch event.type
        when 'tap' then @remove event
      return

  return Notifications
