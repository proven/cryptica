###
TODO: client transport config
io.configure ->
  console.log 'configuring transport'
  io.set 'transports', ['websocket']
###

# TODO: require('jsv')

socket = io.connect('https://localhost:3000', {secure: true})

socket.on 'connect', ->
  console.log 'socket connected'

  password = 'Password'
  secretValue = 'Test'

  message = {
    id : '00000000000000000000000000000000',
    timestamp : '2000-01-01T01:01:01Z',
    encryptedValue : sjcl.encrypt(password, secretValue)
  }

  socket.emit 'addMessage', message, (response) ->
    # TODO: validate
    console.log response.id
    console.log sjcl.decrypt(password, response.encryptedValue)

socket.on 'reconnect', ->
  console.log 'socket reconnected'

socket.on 'reconnecting', ->
  console.log 'socket reconnecting'

# TODO: Decide/determine if error strings are untrusted and should be escaped.
socket.on 'error', (e) ->
  console.log "Error: #{e}"
