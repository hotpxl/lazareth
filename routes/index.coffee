require 'coffee-script/register'
process = require './process.coffee'

predict = (data) ->
  time = (i[0] for i in data)
  return

exports.index = (req, res) ->
  res.render 'index.html'
  return

exports.api = (req, res) ->
  fs = require 'fs'
  path = require 'path'
  fs.readFile path.join(__dirname, '../data/CU.intraday.csv.fmt'), 'ascii',
  (err, data) ->
    if err
      throw err
    raw = JSON.parse data
    predict raw
    list = (raw[i] for i in [0..raw.length - 1] by Math.floor(raw.length, 300))
    list.reverse()
    list.push ['Time', 'Close']
    list.reverse()
    res.json {'query': req.params.name, 'data': list}
  return

process.whatever()
