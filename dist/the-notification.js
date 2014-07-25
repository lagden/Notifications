
/*
theNotification.js - Notifications

It is a plugin that show notification like Growl

@author      Thiago Lagden <lagden [at] gmail.com>
@copyright   Author

Depends:
TweenMax.js
 */
var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

(function(root, factory) {
  if (typeof define === "function" && define.amd) {
    define(['greensock/TweenMax'], factory);
  } else {
    root.TheNotification = factory(root.TweenMax);
  }
})(this, function(TM) {
  'use strict';
  var TheNotification, eventType, hasPointerEvents, hasTouchEvents, isTouch, options, _privados;
  hasPointerEvents = Boolean(window.navigator.pointerEnabled || window.navigator.msPointerEnabled);
  hasTouchEvents = __indexOf.call(window, 'ontouchstart') >= 0;
  isTouch = Boolean(hasTouchEvents || hasPointerEvents);
  eventType = isTouch ? 'touchend' : 'click';
  _privados = {
    getTemplate: function() {
      return ['<h3 class="theNotification__title">{title}</h3>', '<p class="theNotification__msg">{msg}</p>'].join('');
    },
    extend: function() {
      var args, key, out, _i, _len;
      out = out || {};
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        args = arguments[_i];
        if (args === false) {
          continue;
        }
        for (key in args) {
          if (args.hasOwnProperty(key)) {
            out[key] = args[key];
          }
        }
      }
      return out;
    },
    remove: function(item, ev) {
      this.remove(item);
    },
    selfRemove: function(item) {
      setTimeout((function() {
        return this.remove(item);
      }).bind(this), this.opts.duration);
    }
  };
  options = {
    duration: 5000,
    container: null,
    offset: 10
  };
  TheNotification = (function() {
    function TheNotification(opts) {
      if (false === (this instanceof TheNotification)) {
        return new TheNotification(opts);
      }
      this.opts = _privados.extend({}, options, opts);
      this.items = [];
      this.container = this.opts.container || document.body;
      this.template = this.opts.template || _privados.getTemplate();
      return;
    }

    TheNotification.prototype.notifica = function(t, m) {
      var content, item, last, offset, r;
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
      item.setAttribute('data-offset', offset[1]);
      item.addEventListener(eventType, _privados.remove.bind(this, item), false);
      this.items.push(item);
      this.render(item, offset);
    };

    TheNotification.prototype.render = function(item, offset) {
      var from, to;
      this.container.appendChild(item);
      from = {
        y: offset[0],
        opacity: 0
      };
      to = {
        y: offset[1],
        opacity: 1,
        onComplete: _privados.selfRemove.bind(this, item)
      };
      TM.fromTo(item, 0.5, from, to);
    };

    TheNotification.prototype.remove = function(item) {
      var index, to;
      item.removeEventListener(eventType, _privados.remove);
      index = this.items.indexOf(item);
      if (index !== -1) {
        this.items.splice(index, 1);
      }
      to = {
        y: '-=30px',
        opacity: 0,
        onComplete: function() {
          return item.remove();
        }
      };
      TM.to(item, 0.3, to);
    };

    return TheNotification;

  })();
  return TheNotification;
});
