EventEmitter = require('events').EventEmitter
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

  clientHandler = new ClientHandler socket

  socket.on 'disconnect', ->
    clientHandler.clientDisconnected()

  socket.on 'find', ->
    clientHandler.find.apply null, arguments

  socket.on 'findMany', ->
    clientHandler.findMany.apply null, arguments

  socket.on 'findAll', ->
    clientHandler.findAll.apply null, arguments

  socket.on 'createRecord', ->
    clientHandler.createRecord.apply null, arguments

  socket.on 'decryptish', ->
    clientHandler.decryptish.apply null, arguments


store =
  message:
    currentID: 1
    content: []

remoteNewRecordsEmitter = new EventEmitter()

remoteNewRecords = (type, records) ->
  # store in DB
  _.each records, (record) ->
    record.id = store[type].currentID++
    store[type].content.push record
  # Limit the length of the record store
  store[type].content = _.last store[type].content, 100
  # tell clients
  remoteNewRecordsEmitter.emit 'remoteNewRecords', type, records

boringGuySays = ->
  remoteNewRecords 'message', [{user_id: 'Time Guy', message: "Hi again", created_date: new Date()}]
interval = setInterval boringGuySays, 5000

serverDelay = (next) ->
  _.delay next, 1000


class ClientHandler
  constructor: (@socket) ->
    remoteNewRecordsEmitter.addListener 'remoteNewRecords', @remoteNewRecords

  clientDisconnected: =>
    console.log 'clientDisconnected'
    remoteNewRecordsEmitter.removeListener 'remoteNewRecords', @remoteNewRecords
    @socket = null

  decryptish: (ciphertext, callback) =>
    if ciphertext instanceof Array
      callback ciphertext.map (ct) -> ct + '?!'
    else
      callback ciphertext + '?!'

  find: (type, id, callback) =>
    serverDelay =>
      callback _.find store[type].content, (item) -> item.id == id

  findMany: (type, ids, callback) =>
    serverDelay =>
      callback _.filter store[type].content, (item) -> _.contains ids, item.id

  findAll: (type, callback) =>
    serverDelay =>
      callback store[type].content

  createRecord: (type, record, callback) =>
    serverDelay =>
      @createRecords type, [record], (records) -> callback(_.first records)

  createRecords: (type, records, callback) =>
    serverDelay =>
      _.each records, (record) ->
        record.id = store[type].currentID++
        store[type].content.push record
      callback(records)

  remoteNewRecords: (type, records) =>
    @socket.emit 'remoteNewRecords', type, records
