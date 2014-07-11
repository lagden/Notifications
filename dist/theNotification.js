
/*
theNotification.js - Notifications

It is a plugin that show notification like Growl

@author      Thiago Lagden <lagden [at] gmail.com>
@copyright   Author
 */
(function(root, factory) {
  if (typeof define === "function" && define.amd) {
    define(factory);
  } else {
    root.TheNotification = factory();
  }
})(this, function() {
  'use strict';
  var TheNotification, animate, extend, getTemplate, handlerRemove, options;
  getTemplate = function() {
    return ['<h3 class="theNotification__title">{title}</h3>', '<p class="theNotification__msg">{msg}</p>'].join('');
  };
  extend = function() {
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
  };
  animate = function(opts) {
    var run, start;
    start = new Date().getTime();
    run = function() {
      var delta, progress, timePassed;
      timePassed = new Date().getTime() - start;
      progress = timePassed / opts.duration;
      if (progress > 1) {
        progress = 1;
      }
      delta = opts.delta(progress);
      opts.step(delta);
      if (progress === 1) {
        opts.complete();
      } else {
        requestAnimationFrame(run);
      }
    };
    requestAnimationFrame(run);
  };
  handlerRemove = function(item, ev) {
    this.remove(item);
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
      this.opts = extend({}, options, opts);
      this.items = [];
      this.container = this.opts.container || document.body;
      this.template = this.opts.template || getTemplate();
      return;
    }

    return TheNotification;

  })();
  TheNotification.prototype.notifica = function(t, m) {
    var content, item, last, offset, r, that;
    that = this;
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
    item.addEventListener('click', handlerRemove.bind(this, item), false);
    this.items.push(item);
    this.render(item, offset);
  };
  TheNotification.prototype.render = function(item, offset) {
    var from, rm, that, to;
    that = this;
    this.container.appendChild(item);
    item.style.top = offset[0];
    item.style.opacity = 0;
    rm = function() {
      setTimeout((function() {
        that.remove(item);
      }), that.opts.duration);
    };
    from = offset[0];
    to = offset[1];
    animate({
      duration: 500,
      delta: function(p) {
        return 1 - Math.sin(Math.acos(p));
      },
      step: function(d) {
        var t;
        t = parseInt((d * (to - from)) + from, 10);
        item.style.top = t + 'px';
        item.style.opacity = d;
      },
      complete: rm
    });
  };
  TheNotification.prototype.remove = function(item) {
    var from, index, that, to;
    that = this;
    index = this.items.indexOf(item);
    item.removeEventListener('click', handlerRemove);
    if (index === -1) {
      return this;
    }
    this.items.splice(index, 1);
    from = parseInt(item.style.top, 10);
    to = from - 30;
    animate({
      duration: 300,
      delta: function(p) {
        return 1 - Math.sin(Math.acos(p));
      },
      step: function(d) {
        var o, t;
        t = parseInt((d * (to - from)) + from, 10);
        o = (d * (0 - 1)) + 1;
        item.style.top = t + 'px';
        item.style.opacity = o;
      },
      complete: function() {
        that.container.removeChild(item);
      }
    });
  };
  return TheNotification;
});
