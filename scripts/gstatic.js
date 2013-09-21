require('coffee-script');

var contentSource = process.argv[2];
var templates = process.argv[3];
var contentDest = process.argv[4];

if (!contentSource) {
  throw new Error('No content source argument provided.')
}
if (!contentDest) {
  throw new Error('No content destination argument provided.')
}
if (!templates) {
  throw new Error('No template source argument provided.')
}

require('./lib/generate_static').main({
  contentSource: contentSource
, templateSource: templates
, contentDest: contentDest
});