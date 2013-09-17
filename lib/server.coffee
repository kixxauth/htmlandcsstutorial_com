HTTP = require 'http'
URL = require 'url'
ECSTATIC = require 'ecstatic'


class HTTPServer
  server: null
  port: null
  hostname: null
  root: null
  staticServer: null

  constructor: (opts) ->
    @root = opts.root
    @port = 8080
    @hostname = '127.0.0.1'
    @server = HTTP.createServer(@httpHandler())

    # https://github.com/jesusabdullah/node-ecstatic
    @staticServer = ECSTATIC({
      root: @root
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
        self.handleStatic(req, res)

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
    return false

  handleStatic: (req, res) ->
    @staticServer(req, res)
    return true


exports.main = (opts) ->
  opts or= Object.create(null)

  unless opts.root
    throw new Error('opts.root is required')

  process.on('uncaughtException', onUncaughtException)
  server = new HTTPServer(opts).initialize()
  return server


onUncaughtException = (err) ->
  console.error('Uncaught Exception:')
  console.error(err.stack)
  return