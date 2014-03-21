theNotification.js - Notifications
==================================
 
It is a plugin that show notification like Growl
    
### Depends

 - [TweenMax](https://raw.githubusercontent.com/greensock/GreenSock-JS/master/src/uncompressed/TweenMax.js)

### Usage

```javascript

var TheNotification = require('theNotification');
var growl = new TheNotification();

for(var i=-1; ++i < 10;)
    growl.notifica('Count...', i);

```

### Author

[Thiago Lagden](mailto:lagden@gmail.com)