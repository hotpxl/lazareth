require 'coffee-script/register'
process = require './process.coffee'

exports.index = (req, res) ->
  res.render 'index.html'
  return

exports.api = (req, res) ->
  res.json {'query': req.params.name, 'data': process.whatever()}
  # TODO Make process async, and respond in process
  return

