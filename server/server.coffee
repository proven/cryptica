express = require('express')
sio = require('socket.io')
fs = require('fs')

privateKey = fs.readFileSync('../testing.key').toString()
certificate = fs.readFileSync('../testing.crt').toString()

app = express.createServer({key:privateKey, cert:certificate})

app.configure ->
  app.use(express.static(__dirname + 'public'))

app.listen 3000, ->
  addr = app.address()
  console.log(' app listening on ' + addr.address + ':' + addr.port)

io = sio.listen(app, {key:privateKey, cert:certificate})

io.sockets.on 'connection', (socket) ->
  socket.on 'ping', (unsafe_msg) ->
    console.dir socket
    msg = "ping received: #{unsafe_msg}"
    console.log msg
    socket.emit 'pong', msg

  socket.on 'disconnect', ->
    console.log 'socket disconnected'
