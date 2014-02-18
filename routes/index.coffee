require 'coffee-script/register'
process = require './process.coffee'

predict = (data) ->
  time = (i[0] for i in data)
  return

exports.index = (req, res) ->
  res.render 'index.html'
  return

exports.api = (req, res) ->
  console.log process.whatever()
  res.json {'query': req.params.name, 'data': process.whatever()}
  # TODO Make process async, and respond in process
  return

