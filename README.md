Notifications
=============

It is a plugin that show notification like Growl

## Installation

    bower install notifications

### Usage

**AMD**

```javascript
require(['notifications'], function(notifications) {

    'use strict';

    var growl = notifications();
    for(var i=-1; ++i < 10;)
        growl.notifica('Count...', i);
});
```

**Global**

```javascript
var growl = new Notifications({duration: 5000});

for(var i=-1; ++i < 10;)
    growl.notifica('Count...', i);
```

## Author

[Thiago Lagden](http://lagden.in)