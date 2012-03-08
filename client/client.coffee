socket = io.connect('http://localhost:3000')

socket.on 'connect', ->
  console.log 'socket connected'
  socket.emit 'ping', 'first ping'

socket.on 'pong', (unsafe_msg) ->
  console.log "pong: #{unsafe_msg}"

socket.on 'reconnect', ->
  console.log 'socket reconnected'

socket.on 'reconnecting', ->
  console.log 'socket reconnecting'

# TODO: Decide/determine if error strings are untrusted and should be escaped.
socket.on 'error', (e) ->
  console.log "Error: #{e}"
