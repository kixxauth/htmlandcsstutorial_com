require('coffee-script');
 
var PATH = require('path');

var root = PATH.join(__dirname, 'public');

require('./lib/server').main({root: root});