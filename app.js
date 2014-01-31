var express = require('express');
var http = require('http');

var app = express();
app.set('port', 8000);
app.use(express.static(__dirname));
http.createServer(app).listen(app.get('port'), function() {
  console.log('Started');
});
