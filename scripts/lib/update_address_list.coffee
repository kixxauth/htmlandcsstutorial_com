REQ = require 'request'


class APInterface

  constructor: (opts) ->
    @mailgunKey = opts.mailgunKey

  getAddressList: (name, callback) ->
    opts =
      path: "/lists/#{name}/members"
      qs: {limit: 1000}

    @get opts, (err, json) ->
      if err then return callback(err)

      members = json.items
      if members.length > 1000
        err = new Error("Need to lift Mailgun list member query limit.")
        return callback(err)

      callback(null, members)
      return
    return @

  uploadAddressList: (name, addresses, callback) ->
    if addresses.length > 999
      err = new Error("Too many addresses for Mailgun (#{addresses.length}). Limit 1000")
      return callback(err)

    opts =
      path: "/lists/#{name}/members.json"
      form:
        subscribed: true
        members: JSON.stringify(addresses)

    @post opts, (err, json) ->
      if err then return callback(err)
      json.list.message = json.message
      callback(null, json.list)
      return

    return @

  post: (opts, callback) ->
    opts.method = 'POST'
    @rawRequest(opts, callback)
    return @

  get: (opts, callback) ->
    opts.method = 'GET'
    @rawRequest(opts, callback)
    return @

  rawRequest: (opts, callback) ->
    requestOpts =
      method: opts.method
      auth:
        username: "api"
        password: @mailgunKey
      uri: "https://api.mailgun.net/v2#{opts.path}"

    if opts.form then requestOpts.form = opts.form
    if opts.qs then requestOpts.qs = opts.qs

    REQ requestOpts, (err, res, body) ->
      if err then return callback(err)
      callback(null, JSON.parse(body))
      return

    return @


exports.main = (opts) ->
  opts or= {}
  buff = ''
  process.stdin.setEncoding 'utf8'

  unless opts.mailgun_key
    throw new Error("Missing mailgun_key setting.")

  opts.api = new APInterface({mailgunKey: opts.mailgun_key})
  opts.listName = 'developers@kixx.name'

  whenDoneProcessing = (err, res) ->
    if err then throw err
    console.log res
    console.log "DONE!"
    return

  onStdinEnd = ->
    lines = buff.split('\n').filter(filterEmptyLines)
    addresses = lines.map(mapLinesToAddresses)

    opts.api.getAddressList opts.listName, (err, remoteAddresses) ->
      if err then return whenDoneProcessing(err)

      processingOpts =
        api: opts.api
        listName: opts.listName
        localAddresses: addresses
        remoteAddresses: remoteAddresses

      processAddresses(processingOpts, whenDoneProcessing)
      return
    return

  process.stdin.on 'data', (chunk) ->
    buff += chunk
    return

  process.stdin.on('end', onStdinEnd)
  process.stdin.resume()
  return


filterEmptyLines = (line) ->
  if line then return true
  else return false


mapLinesToAddresses = (line) ->
  parts = line.split('\t').filter(filterEmptyLines)
  return {address: parts[0].trim(), name: parts[1].trim()}


processAddresses = (opts, callback) ->
  remote = opts.remoteAddresses.map (addr) ->
    return addr.address.toLowerCase()

  diff = opts.localAddresses.reduce( (diff, addr) ->
    if remote.indexOf(addr.address.toLowerCase()) < 0
      diff.push(addr)
    return diff
  , [])

  if diff.length
    console.log "Uploading:"
    console.log diff
    opts.api.uploadAddressList(opts.listName, diff, callback) 
  else
    callback(null, "No addresses to upload.")
  return
