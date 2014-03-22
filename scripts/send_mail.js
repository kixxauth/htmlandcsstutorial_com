require('coffee-script/register')

var opts = require(process.env['HOME'] + "/.priv/htmlandcsstutorial/settings.json");
opts.listName = process.argv[2];

require('./lib/send_mail').main(opts)
