express = require('express')
sio = require('socket.io')
fs = require('fs')
jsv = require('JSV').JSV
crypto = require('crypto')
mongodb = require('mongodb')

###
Setup JSON schema
###

schema = JSON.parse(fs.readFileSync('../common/test_schema.json').toString())
jsvEnv = JSV.createEnvironment();

###
Express setup
###

privateKey = fs.readFileSync('../testing.key').toString()
certificate = fs.readFileSync('../testing.crt').toString()

app = express.createServer({key:privateKey, cert:certificate})

app.configure ->
  app.use(express.static(__dirname + 'public'))

app.listen 3000, ->
  addr = app.address()
  console.log(' app listening on ' + addr.address + ':' + addr.port)

###
Socket.IO server
###

io = sio.listen(app, {key:privateKey, cert:certificate})

io.configure ->
  io.set 'transports', ['websocket']

io.sockets.on 'connection', (socket) ->

  socket.on 'addMessage', addMessageHandler
  socket.on 'getHistory', getHistoryHandler

  socket.on 'disconnect', ->
    console.log 'socket disconnected'

###
Socket.IO helpers
###

addMessageHandler = (message, responseCallback) ->
  console.dir message
  report = jsvEnv.validate(message, schema.properties.TestMessage)
  if report.errors.length == 0
    console.log 'message valid'
  else
    console.dir report.errors
    console.log 'message invalid'
  message.id = crypto.pseudoRandomBytes(16).toString('hex').toUpperCase()

  storeMessage message, (err, msgObject) ->
    if err?
      return responseCallback('error')
    return responseCallback(null, msgObject)

getHistoryHandler = (responseCallback) ->
  loadMessages (err, results) ->
    if err?
      console.log err
      responseCallback('error')
      return

    console.log(results)
    responseCallback(null, results)

###
MongoDB
###

db = new mongodb.Db('test', new mongodb.Server("127.0.0.1", 27017, {}))

storeMessage = (msgObject, callback) ->
  db.open (err, p_client) ->
    if err? then return callback(err)
    db.collection 'testMessages', (err, collection) ->
      if err? then return callback(err)
      collection.insert msgObject, (err, count) ->
        if err? then return callback(err)
        console.log("inserted #{msgObject.id}")
        callback(null, msgObject)

loadMessages = (callback) ->
  db.open (err, p_client) ->
    if err? then return callback(err)
    db.collection 'testMessages', (err, collection) ->
      if err? then return callback(err)
      collection.find().sort({timestamp:1}).toArray (err, messages) ->
        callback(err, messages)
