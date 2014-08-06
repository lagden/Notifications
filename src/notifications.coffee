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

  # CustomEvent() constructor functionality in Internet Explorer
  unless window.CustomEvent
    (->
      CustomEvent = (event, params) ->
        params = params or
          bubbles: false
          cancelable: false
          detail: undefined

        evt = document.createEvent "CustomEvent"
        evt.initCustomEvent event,
                            params.bubbles,
                            params.cancelable,
                            params.detail
        return evt

      CustomEvent:: = window.Event::
      window.CustomEvent = CustomEvent
      return
    )()

  # Static Private Library
  _SPL =
    getTemplate: () ->
      [
        '<h3 class="theNotification__title">{title}</h3>'
        '<p class="theNotification__msg">{msg}</p>'
      ].join ''

    extend: (a, b) ->
      a[ prop ] = b[ prop ] for prop of b
      return a

    selfRemove: (item, duration) ->
      setTimeout () ->
        # Fires the click event
        item.dispatchEvent(new CustomEvent 'click')

        # Force Garbage Collection
        item = null
        return

      , duration
      return

  # Default Options
  options =
    duration: 5000
    container: null
    offset: 10

  # Notifications
  class Notifications
    constructor: (opts) ->
      return new Notifications opts if (@ instanceof Notifications) is false
      @opts = _SPL.extend options, opts
      @items = []
      @events = {}
      @container = @opts.container or document.body
      @template = @opts.template or _SPL.getTemplate()

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

      # Caching events handlers
      randEventName = 'evt' + String(Math.random() * Date.now()).split('.')[0]
      @events[randEventName] = @remove.bind @

      # Setting attributes
      item.setAttribute 'data-offset', offset[1]
      item.setAttribute 'data-event', randEventName

      # Listener
      item.addEventListener 'click', @events[randEventName], false

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

      # Animation
      from =
        y: offset[0]
        opacity: 0

      to =
        y: offset[1],
        opacity: 1,
        onComplete: _SPL.selfRemove
        onCompleteParams: [item, @opts.duration]

      TM.fromTo item, 0.5, from, to

      # Force Garbage Collection
      item = null
      return

    # Animate and remove item
    remove: (event) ->

      # Getting item
      item = event.currentTarget

      # Getting event handler name and remove listener
      randEventName = item.getAttribute 'data-event'
      item.removeEventListener 'click', @events[randEventName], false

      # Remove binding function
      delete @events[randEventName]

      # Animation
      onCompleteRemove = (item) ->
        index = @items.indexOf item
        if index isnt -1
          @container.removeChild @items[index]
          @items.splice index, 1

        # Force Garbage Collection
        item = null
        return

      to =
        y: '-=30',
        opacity: 0,
        onComplete: onCompleteRemove.bind @, item

      TM.to item, 0.3, to

      # Force Garbage Collection
      item = null
      return

  return Notifications
