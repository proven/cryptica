express = require 'express'
socketio = require 'socket.io'
_ = require 'underscore'

app = express.createServer()
io = socketio.listen(app)

app.listen 3000

app.get '/', (req, res) ->
  res.sendfile(__dirname + '/index.html')

app.use '/', express.static(__dirname + '/')
app.use '/css', express.static(__dirname + '/css')
app.use '/js', express.static(__dirname + '/js')

io.sockets.on 'connection', (socket) ->

  clientConnected socket

  socket.on 'disconnect', ->
    clientDisconnected()

  socket.on 'find', ->
    find.apply null, arguments

  socket.on 'findMany', ->
    findMany.apply null, arguments

  socket.on 'findAll', ->
    findAll.apply null, arguments

  socket.on 'createRecord', ->
    createRecord.apply null, arguments

  socket.on 'decryptish', ->
    decryptish.apply null, arguments


store =
  message:
    currentID: 1
    content: []

# Hack
clientSocket = null
interval = null

clientConnected = (socket) ->
  console.log 'clientConnected'
  clientSocket = socket

  timeGuySays = ->
    remoteNewRecords 'message', [{user_id: 'Time Guy', message: new Date().toLocaleString()}]
  interval = setInterval timeGuySays, 5000

clientDisconnected = ->
  console.log 'clientDisconnected'
  clearInterval interval if interval
  interval = null
  clientSocket = null

decryptish = (ciphertext, callback) ->
  if ciphertext instanceof Array
    callback ciphertext.map (ct) -> ct + '?!'
  else
    callback ciphertext + '?!'

find = (type, id, callback) ->
  callback _.find store[type].content, (item) -> item.id == id

findMany = (type, ids, callback) ->
  callback _.filter store[type].content, (item) -> _.contains ids, item.id

findAll = (type, callback) ->
  callback store[type].content

createRecord = (type, record, callback) ->
  createRecords type, [record], (records) -> callback(_.first records)

createRecords = (type, records, callback) ->
  _.each records, (record) ->
    record.id = store[type].currentID++
    store[type].content.push record
  callback(records)

remoteNewRecords = (type, records) ->
  # store in DB
  _.each records, (record) ->
    record.id = store[type].currentID++
    store[type].content.push record
  # tell client
  if clientSocket
    clientSocket.emit 'remoteNewRecords', type, records

