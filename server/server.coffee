express = require('express')
sio = require('socket.io')
fs = require('fs')
jsv = require('JSV').JSV;
crypto = require('crypto')

privateKey = fs.readFileSync('../testing.key').toString()
certificate = fs.readFileSync('../testing.crt').toString()

schema = JSON.parse(fs.readFileSync('../common/test_schema.json').toString())

jsvEnv = JSV.createEnvironment();

app = express.createServer({key:privateKey, cert:certificate})

app.configure ->
  app.use(express.static(__dirname + 'public'))

app.listen 3000, ->
  addr = app.address()
  console.log(' app listening on ' + addr.address + ':' + addr.port)

io = sio.listen(app, {key:privateKey, cert:certificate})

io.configure ->
  io.set 'transports', ['websocket']

io.sockets.on 'connection', (socket) ->

  socket.on 'addMessage', (message, responseCallback) ->
    console.dir message
    report = jsvEnv.validate(message, schema.properties.TestMessage)
    if report.errors.length == 0
      console.log 'message valid'
    else
      console.dir report.errors
      console.log 'message invalid'
    message.id = crypto.pseudoRandomBytes(16).toString('hex').toUpperCase()
    responseCallback(message)


  socket.on 'disconnect', ->
    console.log 'socket disconnected'
