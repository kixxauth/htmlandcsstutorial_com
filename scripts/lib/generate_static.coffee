FS    = require 'fs'
NPATH = require 'path'

PATH   = require 'filepath'
MARKED = require 'marked'
SWIG   = require 'swig'


readFile = (filepath, callback) ->
  FS.readFile(filepath, 'utf8', callback)
  return


markdown2HTML = (filepath, callback) ->
  opts =
    smartypants: on

  readFile filepath, (err, text) ->
    if err then return callback(err)
    MARKED(text, opts, callback)
    return
  return


template = (templatePath, context) ->
  engine = new SWIG.Swig({
    autoescape: off
  })
  func = engine.compileFile(templatePath)
  return func(context)


generateContent = (templates, filepath, callback) ->

  withFrontMatter = (frontMatter) ->
    if frontMatter is null
      throw new Error("Front matter file missing for #{filepath}")

    if NPATH.extname(filepath) is '.md'
      composeMarkdown(filepath, frontMatter, doTemplate)
    else
      composeFile(filepath, frontMatter, doTemplate)
    return

  doTemplate = (err, context) ->
    if err then return callback(err)
    composeTemplate(templates, context, callback)
    return

  frontMatter = filepath.replace(/md$/, 'ini')
  PATH.newPath(frontMatter).read({parser: 'ini'})
    .then(withFrontMatter).failure(callback)
  return


composeMarkdown = (filepath, context, callback) ->
  markdown2HTML filepath, (err, content) ->
    if err then return callback(err)
    context.content = content
    return callback(null, context)
  return


composeFile = (filepath, context, callback) ->
  readFile filepath, (err, content) ->
    if err then return callback(err)
    context.content = content
    return callback(null, context)
  return


composeTemplate = (templates, context, callback) ->
  process.nextTick ->
    try
      html = template(NPATH.join(templates, 'index.html'), context)
    catch err
      return callback(err)
    return callback(null, html)
  return


handleError = (err) ->
  if err
    process.exit(1)
  return


exports.main = (opts) ->
  {contentSource, templateSource, contentDest} = opts

  src = PATH.newPath(contentSource).resolve()

  chop = src.toString()
  if chop.charAt(chop.length - 1) isnt '/'
    chop += '/'

  src.recurse (filepath) ->
    return unless filepath.isFile()

    stringPath = filepath.toString().replace(chop, '')
    ext = NPATH.extname(stringPath)
    unless ext is '.md' or ext is '.html'
      return

    generateContent templateSource, filepath.toString(), (err, content) ->
      handleError(err)
      console.log("DONE")
      return
    return
	return
