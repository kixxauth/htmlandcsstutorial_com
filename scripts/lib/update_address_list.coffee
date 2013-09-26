MAILER = require './mailgun_api'
STDIN  = require './read_stdin'


exports.main = (opts) ->
  opts or= {}

  unless opts.mailgun_key
    throw new Error("Missing mailgun_key setting.")

  opts.api = MAILER.newMailgun({mailgunKey: opts.mailgun_key})
  opts.listName = 'developers@kixx.name'

  whenDoneProcessing = (err, res) ->
    if err then throw err
    console.log res
    console.log "DONE!"
    return

  STDIN.read (err, buff) ->
    if err then return whenDoneProcessing(err)

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
