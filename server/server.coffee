express = require('express')
sio = require('socket.io')


app = express.createServer()

app.configure ->
  app.use(express.static(__dirname + 'public'))

app.listen 3000, ->
  addr = app.address();
  console.log(' app listening on http://' + addr.address + ':' + addr.port)

io = sio.listen(app)

io.sockets.on 'connection', (socket) ->
  socket.on 'ping', (unsafe_msg) ->
    console.dir socket
    msg = "ping received: #{unsafe_msg}"
    console.log msg
    socket.emit 'pong', msg

  socket.on 'disconnect', ->
    console.log 'socket disconnected'
