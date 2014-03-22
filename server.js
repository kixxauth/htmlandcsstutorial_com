require('coffee-script/register');

var PATH = require('path');

var address = parseAddress(process.argv[2] || '127.0.0.1:8080');

var root = PATH.join(__dirname, 'public');

require('./lib/server').main({
  root: root,
  port: address.port,
  hostname: address.hostname
});

function parseAddress(address) {
  var rv = {port: null, hostname: null}
    , parts = address.split(':')
    , port

  if (port = parts[1]) {
    rv.port = parseInt(port, 10);
  } else {
    rv.port = 80;
  }

  rv.hostname = parts[0];
  return rv;
}