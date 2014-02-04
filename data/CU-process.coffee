fs = require 'fs'
moment = require 'moment'

fs.readFile 'CU.intraday.csv', 'ascii', (err, data) ->
  if err
    throw err
  raw = data.split('\n')[1..-2]
  fs.writeFile 'CU.intraday.csv.fmt', JSON.stringify(do ->
    for i in raw
      do ->
        [time, close] = i.split(',')[1..2]
        [
          if (m = moment(time, 'YYYYMMDD-HH-mm-ss-SSS')).isValid()
          then m.toISOString()
          else throw new EvalError 'Time illegal',
          parseInt close
        ]
  ), (err) ->
    if err
      throw err
    console.log 'Done'


