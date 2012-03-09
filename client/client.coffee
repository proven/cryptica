###
TODO: client transport config
io.configure ->
  console.log 'configuring transport'
  io.set 'transports', ['websocket']
###

# TODO: require('jsv')

password = 'Password'

socket = io.connect('https://localhost:3000', {secure: true})

socket.on 'connect', ->
  console.log 'socket connected'

  now = (new Date()).toISOString()
  secretValue = 'Test @ ' + now

  message = {
    id : '00000000000000000000000000000000',
    timestamp : now,
    encryptedValue : sjcl.encrypt(password, secretValue)
  }

  addMessage(socket, message)
  getHistory(socket)

socket.on 'reconnect', ->
  console.log 'socket reconnected'

socket.on 'reconnecting', ->
  console.log 'socket reconnecting'

# TODO: Decide/determine if error strings are untrusted and should be escaped.
socket.on 'error', (e) ->
  console.log "Error: #{e}"

###
Helpers
###

getHistory = (socket) ->
  socket.emit 'getHistory', (err, messages) ->
    if err?
      console.log "getHistory failed: #{err}"
      return
    console.log 'getHistory returned: '+messages.length
    # TODO: validate
    _.forEach messages, (message) ->
      console.log "message: #{message.id}: #{sjcl.decrypt(password, message.encryptedValue)}"

addMessage = (socket, message) ->
  socket.emit 'addMessage', message, (err, response) ->
    if err?
      console.log "addMessage failed: #{err}"
      return
    # TODO: validate
    console.log response.id
    console.log sjcl.decrypt(password, response.encryptedValue)
