# server
http = require 'http'
ecstatic = require 'ecstatic'
shoe = require 'shoe'
through = require 'through'

# persistence
level = require 'levelup'
sublevel = require 'level-sublevel'
scuttlebutt = require 'level-scuttlebutt'
udid = require('udid')('example')
{Doc} = require 'crdt'

# setup database
DB = sublevel level "#{__dirname}/_db"
db = DB.sublevel 'docs'
scuttlebutt db, udid, (name) -> new Doc

# setup server
server = http.createServer ecstatic {root: __dirname}

sock = shoe (stream) ->
  pauser = through()
  stream.pipe(pauser.pause()).pipe(stream)

  db.open 'doc', (err, doc) ->
    pauser.pipe(doc.createStream()).pipe pauser
    pauser.resume()

    console.log 'latest connetion:', latest = (new Date).toISOString()

    doc.set 'connections', {latest}

sock.install server, '/stream'

server.listen 3332, -> console.log 'listening on http://localhost:3332'
