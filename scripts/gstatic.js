require('coffee-script');

var contentSource = process.argv[2];
var contentDest = process.argv[3];

if (!contentSource) {
  throw new Error('No content source argument provided.')
}
if (!contentDest) {
  throw new Error('No content destination argument provided.')
}

require('./lib/generate_static').main({
  contentSource: contentSource
, contentDest: contentDest
});