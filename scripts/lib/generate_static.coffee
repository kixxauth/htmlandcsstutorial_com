FS    = require 'fs'
NPATH = require 'path'

PATH   = require 'filepath'
MARKED = require 'marked'
SWIG   = require 'swig'


isTextFile = (filepath) ->
  x = NPATH.extname(filepath)
  if x is '' or x is '.md' or x is '.html' or x is '.svg' or x is '.css' or x is '.javascript'
    return yes
  return no


readFile = (filepath, callback) ->
  encoding = if isTextFile(filepath) then 'utf8' else null
  FS.readFile(filepath, encoding, callback)
  return


writeFile = (filepath, text, callback) ->
  encoding = if isTextFile(filepath) then 'utf8' else null
  FS.writeFile(filepath, text, {encoding: encoding}, callback)
  return


copyFile = (filepath, destination, callback) ->
  readFile filepath, (err, text) ->
    if err then return callback(err)
    return writeFile(destination, text, callback)
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
    frontMatter or= Object.create(null)

    if NPATH.extname(filepath) is '.md'
      composeMarkdown(filepath, frontMatter, doTemplate)
    else
      composeFile(filepath, frontMatter, doTemplate)
    return

  doTemplate = (err, context) ->
    if err then return callback(err)
    composeTemplate(templates, context, callback)
    return

  frontMatter = filepath.replace(/(md|html)$/, 'ini')
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
    console.log(err.stack)
    process.exit(1)
  return


exports.main = (opts) ->
  {contentSource, templateSource, contentDest} = opts

  src = PATH.newPath(contentSource).resolve()
  destination = PATH.newPath(contentDest).resolve()

  chop = src.toString()
  if chop.charAt(chop.length - 1) isnt '/'
    chop += '/'

  src.recurse (filepath) ->
    return unless filepath.isFile()

    relpath = filepath.toString().replace(chop, '')
    abspath = NPATH.join(destination.toString(), relpath)

    ext = NPATH.extname(filepath)
    unless ext is '.md' or ext is '.html'
      unless ext is '.ini'
        PATH.newPath(NPATH.dirname(abspath)).mkdir()
        copyFile(filepath.toString(), abspath, handleError)
      return

    unless /index\.html$/.test(relpath)
      relpath = relpath.replace(NPATH.extname(relpath), '')
      abspath = abspath.replace(NPATH.extname(abspath), '')

    generateContent templateSource, filepath.toString(), (err, content) ->
      handleError(err)
      PATH.newPath(NPATH.dirname(abspath)).mkdir()
      writeFile(abspath, content, handleError)
      return
    return
	return
