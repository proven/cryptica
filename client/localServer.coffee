express = require('express')

app = express.createServer()

app.configure ->
  app.use(express.static(__dirname))

app.listen 3001, ->
  addr = app.address();
  console.log(' app listening on http://' + addr.address + ':' + addr.port)
