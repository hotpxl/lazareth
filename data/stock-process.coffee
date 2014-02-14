fs = require 'fs'
moment = require 'moment'

fs.readFile 'stock.csv', 'ascii', (err, data) ->
  if err
    throw err
  raw = data.split('\n')[..-2]
  fs.writeFile 'stock.csv.fmt', JSON.stringify(do ->
    for i in raw
      do ->
        [date, time, close] = i.split(',')[0..2]
        if time.length == 5
          time = '0' + time
        [
          do ->
            if (m = moment.utc("#{date}-#{time}", 'YYYYMMDD-HHmmss')).isValid()
              m.toISOString()
            else
              console.log "#{date}-#{time}"
              throw new EvalError 'Time illegal',
          parseFloat close
        ]
  ), (err) ->
    if err
      throw err
    console.log 'Done'


