# server
http = require 'http'
ecstatic = require 'ecstatic'
shoe = require 'shoe'

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
  db.open 'doc', (err, doc) ->
    stream.pipe(doc.createStream()).pipe stream

    console.log 'latest connetion:', latest = (new Date).toISOString()

    doc.set 'connections', {latest}

sock.install server, '/stream'

server.listen 3332, -> console.log 'listening on http://localhost:3332'
