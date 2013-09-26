
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


# opts.mailgunKey
exports.newMailgun = (opts) ->
  return new APInterface(opts)