express = require('express')
socketio = require('socket.io')

app = express.createServer()
io = socketio.listen(app)

app.listen 3000

app.get '/', (req, res) ->
  res.sendfile(__dirname + '/index.html')

app.use '/', express.static(__dirname + '/')
app.use '/css', express.static(__dirname + '/css')
app.use '/js', express.static(__dirname + '/js')

currentID = 0

io.sockets.on 'connection', (socket) ->

  postMessages = ->
    messages = []
    for i in [0...2]
      messages.push
        id: currentID++
        user_id: 'userID'+currentID
        message: 'pushed-message'+currentID
    socket.emit 'newMessages', messages

  interval = setInterval postMessages, 5000

  socket.on 'disconnect', ->
    clearInterval interval


  socket.on 'find', (id, callback) ->
    console.log 'request: find: ' + id
    callback
      id: id
      user_id: 'userID'+id
      message: 'find-message'+id

  socket.on 'findAll', (callback) ->
    console.log 'request: findAll'
    allObjs = []
    for id in [0...5]
      allObjs.push
        id: id
        user_id: 'userID'+id
        message: 'findAll-message'+id
    callback allObjs

  socket.on 'decryptish', (ciphertext, callback) ->
    if ciphertext instanceof Array
      callback ciphertext.map (ct) -> ct + '::decryptished'
    else
      callback ciphertext + '::decryptished'
