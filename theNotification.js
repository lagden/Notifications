/**
 * theNotification.js - Notifications
 *
 * It is a plugin that show notification like Growl
 *
 * @author      Thiago Lagden <lagden [at] gmail.com>
 * @copyright   Author
 * @depends:
 *   TweenMax - https://raw.githubusercontent.com/greensock/GreenSock-JS/blob/{version}/src/uncompressed/TweenMax.js
 */

// http://forums.greensock.com/topic/7145-using-with-requirejs/#entry26768
// window.GreenSockAMDPath = 'greensock';

(function(root, factory) {
    if (typeof define === 'function' && define.amd) {
        define(['greensock/TweenMax'], function(TM) {
            return (root.amdWebGlobal = factory(TM));
        });
    } else {
        root.amdWebGlobal = factory(root.TM);
    }
}(this, function(TM) {

    'use strict';

    var options = {
        duration: 5000,
        container: null,
        offset: 10
    };

    var handlerRemove;

    function TheNotification(opts) {
        if (false === (this instanceof TheNotification)) {
            return new TheNotification(opts);
        }
        this.opts = extend({}, options, opts);
        this.items = [];
        this.container = this.opts.container || document.body;
        this.template = this.opts.template || getTemplate();
    }

    TheNotification.prototype.notifica = function(t, m) {
        var that = this;
        var content = this.template.replace(/\{title\}/g, t);
        content = content.replace(/\{msg\}/g, m);

        var item = document.createElement('div');
        item.className = 'theNotification';
        item.style.opacity = 0;
        item.insertAdjacentHTML('afterbegin', content);

        var offset = [0, this.opts.offset];
        var last = this.items[this.items.length - 1];
        if (last) {
            offset[0] = parseInt(last.getAttribute('data-offset'), 10);
            offset[1] = parseInt(offset[0] + last.offsetHeight + this.opts.offset, 10);
        }

        item.setAttribute('data-offset', offset[1]);

        handlerRemove = function(ev) {
            that.remove(item);
        }

        item.addEventListener('click', handlerRemove, false);

        this.items.push(item);
        this.render(item, offset);
    };

    // Alias
    TheNotification.prototype.alert = function(t, m) {
        this.notifica(t, m);
    };

    TheNotification.prototype.render = function(item, offset) {
        var that = this;
        this.container.appendChild(item);
        TM.fromTo(item, .5, {
            top: offset[0],
            opacity: 0
        }, {
            top: offset[1],
            opacity: 1,
            onComplete: function() {
                setTimeout(function() {
                    that.remove(item);
                }, that.opts.duration);
            }
        });
    };

    TheNotification.prototype.remove = function(item) {
        var that = this;
        var index = this.items.indexOf(item);
        item.removeEventListener('click', handlerRemove, false);
        if (index == -1) return this;
        this.items.splice(index, 1);
        TM.to(item, .3, {
            top: '-=30px',
            opacity: 0,
            onComplete: function() {
                that.container.removeChild(item);
            }
        });
    };

    function getTemplate() {
        return '' +
            '<h3 class="theNotification__title">{title}</h3>' +
            '<p class="theNotification__msg">{msg}</p>';
    }

    function extend(out) {
        out = out || {};
        for (var i = 0; ++i < arguments.length;) {
            if (!arguments[i])
                continue;

            for (var key in arguments[i])
                if (arguments[i].hasOwnProperty(key))
                    out[key] = arguments[i][key];
        }
        return out;
    }

    return TheNotification;
}));