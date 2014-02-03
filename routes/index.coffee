exports.index = (req, res) ->
  res.render 'index.html'
  return

exports.api = (req, res) ->
  fs = require 'fs'
  path = require 'path'
  fs.readFile path.join(__dirname, '../data/table'), 'ascii', (err, data) ->
    if err
      throw err
    list = []
    raw = data.split('\n')[1...-1]
    list.push [i.split(',')[0], parseFloat(i.split(',')[4])] for i in raw
    list.push ['Time', 'Close']
    list.reverse()
    res.json {'query': req.params.name, 'data': list}
  return
