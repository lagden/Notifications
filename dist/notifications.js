
/*
notification.js - Notifications

It is a plugin that show notification like Growl

@author      Thiago Lagden <lagden [at] gmail.com>
@copyright   Author
 */
(function(root, factory) {
  if (typeof define === 'function' && define.amd) {
    define(['TweenMax', 'Tap'], factory);
  } else {
    root.Notifications = factory(root.TweenMax, root.Tap);
  }
})(this, function(TM, Tap) {
  'use strict';
  var Notifications, extend, options;
  extend = function(a, b) {
    var prop;
    for (prop in b) {
      a[prop] = b[prop];
    }
    return a;
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
      this.opts = extend(options, opts);
      this.items = [];
      this.events = {};
      this.container = this.opts.container || document.body;
      this.template = this.opts.template || this.getTemplate();
    }

    Notifications.prototype.getTemplate = function() {
      return ['<h3 class="theNotification__title">{title}</h3>', '<p class="theNotification__msg">{msg}</p>'].join('');
    };

    Notifications.prototype.notifica = function(t, m) {
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
      new Tap(item);
      item.addEventListener('tap', this, false);
      this.items.push(item);
      this.put(item, offset);
      item = null;
    };

    Notifications.prototype.put = function(item, offset) {
      var selfRemove;
      this.container.appendChild(item);
      selfRemove = function(item, duration) {
        var t;
        t = setTimeout(function() {
          item.dispatchEvent(new Event('tap'));
          item = null;
          clearTimeout(t);
        }, duration);
      };
      TM.fromTo(item, 0.5, {
        y: offset[0],
        opacity: 0
      }, {
        y: offset[1],
        opacity: 1,
        onComplete: selfRemove,
        onCompleteParams: [item, this.opts.duration]
      });
      item = null;
    };

    Notifications.prototype.remove = function(event) {
      var item, onCompleteRemove;
      event.preventDefault();
      item = event.currentTarget;
      item.removeEventListener('tap', this, false);
      onCompleteRemove = (function(_this) {
        return function(item) {
          var index;
          index = _this.items.indexOf(item);
          if (index !== -1) {
            _this.container.removeChild(_this.items[index]);
            _this.items.splice(index, 1);
          }
          item = null;
        };
      })(this);
      TM.to(item, 0.3, {
        y: '-=30',
        opacity: 0,
        onComplete: onCompleteRemove,
        onCompleteParams: [item]
      });
      item = null;
    };

    Notifications.prototype.handleEvent = function(event) {
      switch (event.type) {
        case 'tap':
          this.remove(event);
      }
    };

    return Notifications;

  })();
  return Notifications;
});
