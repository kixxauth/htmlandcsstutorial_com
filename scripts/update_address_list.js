require('coffee-script/register');

var opts = require(process.env['HOME'] + "/.priv/htmlandcsstutorial/settings.json");

require('./lib/update_address_list').main(opts);
