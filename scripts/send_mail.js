require('coffee-script')

var opts = require(process.env['HOME'] + "/.priv/htmlandcsstutorial/settings.json");

require('./lib/send_mail').main(opts)
