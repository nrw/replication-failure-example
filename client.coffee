# display
domready = require 'domready'
widget = require 'reconnect-widget'

# data
reconnect = require('reconnect-core')(require 'shoe')
{Doc} = require 'crdt'

domready ->
  # div that shows timestamp
  target = document.getElementById 'doc'
  window.doc = doc = new Doc
  # display changes to user
  draw = ->
    target.textContent = 'latest: ' + doc.get('connections')?.get('latest')
  doc.on 'create', draw
  doc.on 'row_update', draw

  recon = (stream) ->
    # wire up the doc stream
    stream.pipe(doc.createStream()).pipe stream

  r = reconnect({}, recon).connect '/stream'

  # show reconnect widget
  document.body.appendChild(widget(r))
