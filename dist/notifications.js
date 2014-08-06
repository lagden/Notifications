
/*
notification.js - Notifications

It is a plugin that show notification like Growl

@author      Thiago Lagden <lagden [at] gmail.com>
@copyright   Author

Depends:
TweenMax.js
 */
(function(root, factory) {
  if (typeof define === "function" && define.amd) {
    define(['greensock/TweenMax'], factory);
  } else {
    root.Notifications = factory(root.TweenMax);
  }
})(this, function(TM) {
  'use strict';
  var Notifications, options, _SPL;
  if (!window.CustomEvent) {
    (function() {
      var CustomEvent;
      CustomEvent = function(event, params) {
        var evt;
        params = params || {
          bubbles: false,
          cancelable: false,
          detail: void 0
        };
        evt = document.createEvent("CustomEvent");
        evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
        return evt;
      };
      CustomEvent.prototype = window.Event.prototype;
      window.CustomEvent = CustomEvent;
    })();
  }
  _SPL = {
    getTemplate: function() {
      return ['<h3 class="theNotification__title">{title}</h3>', '<p class="theNotification__msg">{msg}</p>'].join('');
    },
    extend: function(a, b) {
      var prop;
      for (prop in b) {
        a[prop] = b[prop];
      }
      return a;
    },
    selfRemove: function(item, duration) {
      setTimeout(function() {
        item.dispatchEvent(new CustomEvent('click'));
        item = null;
      }, duration);
    }
  };
  options = {
    duration: 5000,
    container: null,
    offset: 10
  };
  Notifications = (function() {
    function Notifications(opts) {
      if ((this instanceof Notifications) === false) {
        return new Notifications(opts);
      }
      this.opts = _SPL.extend(options, opts);
      this.items = [];
      this.events = {};
      this.container = this.opts.container || document.body;
      this.template = this.opts.template || _SPL.getTemplate();
    }

    Notifications.prototype.notifica = function(t, m) {
      var content, item, last, offset, r, randEventName;
      r = {
        title: t,
        msg: m
      };
      content = this.template.replace(/\{(.*?)\}/g, function(a, b) {
        return r[b];
      });
      item = document.createElement('div');
      item.className = 'theNotification';
      item.style.opacity = 0;
      item.insertAdjacentHTML('afterbegin', content);
      offset = [0, this.opts.offset];
      last = this.items[this.items.length - 1];
      if (last) {
        offset[0] = parseInt(last.getAttribute('data-offset'), 10);
        offset[1] = parseInt(offset[0] + last.offsetHeight + this.opts.offset, 10);
      }
      randEventName = 'evt' + String(Math.random() * Date.now()).split('.')[0];
      this.events[randEventName] = this.remove.bind(this);
      item.setAttribute('data-offset', offset[1]);
      item.setAttribute('data-event', randEventName);
      item.addEventListener('click', this.events[randEventName], false);
      this.items.push(item);
      this.put(item, offset);
      item = null;
    };

    Notifications.prototype.put = function(item, offset) {
      var from, to;
      this.container.appendChild(item);
      from = {
        y: offset[0],
        opacity: 0
      };
      to = {
        y: offset[1],
        opacity: 1,
        onComplete: _SPL.selfRemove,
        onCompleteParams: [item, this.opts.duration]
      };
      TM.fromTo(item, 0.5, from, to);
      item = null;
    };

    Notifications.prototype.remove = function(event) {
      var item, onCompleteRemove, randEventName, to;
      item = event.currentTarget;
      randEventName = item.getAttribute('data-event');
      item.removeEventListener('click', this.events[randEventName], false);
      delete this.events[randEventName];
      onCompleteRemove = function(item) {
        var index;
        index = this.items.indexOf(item);
        if (index !== -1) {
          this.container.removeChild(this.items[index]);
          this.items.splice(index, 1);
        }
        item = null;
      };
      to = {
        y: '-=30',
        opacity: 0,
        onComplete: onCompleteRemove.bind(this, item)
      };
      TM.to(item, 0.3, to);
      item = null;
    };

    return Notifications;

  })();
  return Notifications;
});
