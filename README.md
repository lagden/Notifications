the-notification.js - Notifications
===================================

It is a plugin that show notification like Growl

## Installation

    bower install notifications

### Usage

**RequireJS**

```javascript
var growl = require('theNotification')();

for(var i=-1; ++i < 10;)
    growl.notifica('Count...', i);
```

**Global**

```javascript

var growl = new TheNotification({duration: 5000});

for(var i=-1; ++i < 10;)
    growl.notifica('Count...', i);

```

### Author

[Thiago Lagden](http://lagden.in)