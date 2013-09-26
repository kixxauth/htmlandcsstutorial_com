MAILER = require './mailgun_api'
STDIN  = require './read_stdin'


# otps.mailgun_key
# opts.listName
exports.main = (opts) ->
  opts or= {}

  unless opts.mailgun_key
    throw new Error("Missing mailgun_key setting.")

  unless opts.listName
    throw new Error("Missing listName argument.")

  opts.api = MAILER.newMailgun({mailgunKey: opts.mailgun_key})

  whenDoneProcessing = (err, res) ->
    if err then throw err
    console.log res
    console.log "DONE!"
    return

  STDIN.read (err, buff) ->
    if err then return whenDoneProcessing(err)

    lines = buff.split('\n')
    subject = lines.shift()
    body = lines.join('\n')

    email =
      to: opts.listName
      subject: subject
      text: body

    opts.api.sendMessage(email, whenDoneProcessing)
    return

  return
