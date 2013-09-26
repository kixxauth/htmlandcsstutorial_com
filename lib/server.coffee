HTTP = require 'http'
URL  = require 'url'
QS   = require 'querystring'
FS   = require 'fs'

ECSTATIC = require 'ecstatic'

DATA_FILE = '/var/htmlandcsstutorial_com/data/dev_subscribers'


class HTTPServer
  server: null
  port: null
  hostname: null
  root: null
  staticServer: null

  constructor: (opts) ->
    @root = opts.root
    @port = opts.port
    @hostname = opts.hostname
    @server = HTTP.createServer(@httpHandler())

    # https://github.com/jesusabdullah/node-ecstatic
    @staticServer = ECSTATIC({
      root: @root
      defaultExt: 'html'
    })

  initialize: ->
    @server.on('error', @serverErrorHandler())
    @server.listen(@port, @hostname, @serverListenHandler())
    return @

  httpHandler: ->
    self = @

    handler = (req, res) ->
      url = URL.parse(req.url)
      pathname = decodeURI(url.pathname)

      unless self.handleSubscriber(pathname, req, res)
        self.handleStatic(pathname, req, res)

      return
    return handler

  serverErrorHandler: ->
    self = @
    handler = (err) ->
      console.error('Server Error:')
      console.error(err.stack)
      return
    return handler

  serverListenHandler: ->
    self = @
    handler = ->
      {address, port} = self.server.address()
      console.log "Serving on #{address}:#{port} from #{self.root}"
      return
    return handler

  handleSubscriber: (pathname, req, res) ->
    unless /\/subscribers/.test(pathname) and req.method is "POST"
      return false

    body = ''

    req.setEncoding('utf8')
    req.on 'data', (chunk) ->
      body += chunk
      return

    req.on 'end', =>
      @processSubscriber(req, res, body)
      return

    return true

  processSubscriber: (req, res, body) ->
    if body.length > 999
      return @handleIntruder(req, res, "request body too large")
    if body.length < 4
      return @handleIntruder(req, res, "request body too small")

    try
      data = QS.parse(body)
    catch parseErr
      console.error('form-urlencoded parsing error:')
      console.error(parseErr.stack)
      return @handleIntruder(req, res, "form-urlencoded parsing error")
    
    recordSubscriber(data)
    html = """<html><head><title>Thanks</title></head>
    <body><p>Thanks for subscribing</p></body>
    <html>"""
    res.writeHead(201, {
      'Content-Length': html.length
      'Content-Type': 'text/html'
    })
    res.end(html)
    return

  handleIntruder: (req, res, reason) ->
    console.log("Intrusion handling for: #{reason}")
    html = """<html><head><title>Invalid Request</title></head>
    <body><p>That was an invalid request.</p></body>
    <html>"""
    res.writeHead(400, {
      'Content-Length': html.length
      'Content-Type': 'text/html'
    })
    res.end(html)
    return

  handleStatic: (pathname, req, res) ->
    req.url = @rewritePageURL(req.url)
    @staticServer(req, res)
    return true

  rewritePageURL: (url) ->
    if /\/blog\//.test(url)
      parsed = URL.parse(url)
      return "#{parsed.pathname}.html#{parsed.search or ''}"
    return url



exports.main = (opts) ->
  opts or= Object.create(null)

  unless opts.root
    throw new Error('opts.root is required')

  process.on('uncaughtException', onUncaughtException)
  server = new HTTPServer(opts).initialize()
  return server


recordSubscriber = (data) ->
  data or= Object.create(null)
  name = data.first_name or 'NIL'
  email = data.email or 'NIL'
  record = "#{email}\t\t#{name}\n"

  FS.appendFile DATA_FILE, record, {encoding: 'utf8'}, (err) ->
    if err
      console.error("Error writing data file:")
      console.error(err.stack)
    return
  return


onUncaughtException = (err) ->
  console.error('Uncaught Exception:')
  console.error(err.stack)
  return