require 'coffee-script/register'
process = require './process.coffee'
_ = require 'underscore'

combineIntoChartData = (title, data...) ->
  ret = [title]
  ret.concat _.zip.apply(this, data)

exports.index = (req, res) ->
  res.render 'index.html'
  return

exports.api = (req, res) ->
  res.json {'query': req.params.name, 'data': process.whatever()}
  # TODO Make process async, and respond in process
  return

