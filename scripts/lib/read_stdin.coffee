exports.read = (callback) ->
  buff = ''
  process.stdin.setEncoding 'utf8'

  process.stdin.on 'data', (chunk) ->
    buff += chunk
    return

  process.stdin.on 'end', ->
    callback(null, buff)
    return

  process.stdin.on 'error', ->
    callback(err)
    return

  process.stdin.resume()
  return