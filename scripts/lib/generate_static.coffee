PATH = require 'filepath'
exports.main = (opts) ->
  {contentSource, contentDest} = opts

  src = PATH.newPath(contentSource).resolve()

  chop = src.toString()
  if chop.charAt(chop.length - 1) isnt '/'
    chop += '/'

  src.recurse (filepath) ->
    return unless filepath.isFile()

    filepath = filepath.toString().replace(chop, '')
    console.log filepath
    return
	return