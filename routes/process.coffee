fs = require 'fs'
path = require 'path'
moment = require 'moment'
assert = require 'assert'
_ = require 'underscore'

class Transaction

  constructor: (@rollback, @cutoff, @maxAF, @stepSize) ->
    if @cutoff < @rollback
      throw new Error 'Rollback larger than cutoff'

  processDay: (data, ret) ->
    last =
      trade: 0
      position: 0
      extreme: 0
      af: 0
      sar: 0
      price: 0
      openPrice: 0
      return: ret
      max: parseFloat data[0][2]
      min: parseFloat data[0][3]
    # Data here should be of one day
    for i in [0..data.length - 1]
      now =
        trade: 0
        position: last.position
        extreme: 0
        af: 0
        sar: last.sar
        price: parseFloat data[i][1]
        openPrice: last.openPrice
        return: last.return
        max: last.max
        min: last.min
      if @rollback < i # Set rollback maximum and minimum
        do =>
          max = parseFloat data[i - @rollback][2]
          min = parseFloat data[i - @rollback][3]
          now.max = if last.max < max then max else last.max
          now.min = if min < last.min then min else last.min
      if last.position # SAR
        if i == data.length - 1 # Force cover at the end of day
          now.trade = -last.position
        else
          if last.position == 1
            now.extreme = do =>
              high = parseFloat data[i][2]
              if last.extreme < high then high else last.extreme
            now.af = do =>
              t = last.af + (last.extreme < now.extreme) * @stepSize
              if t < @maxAF then t else @maxAF
            now.sar = last.sar + (last.extreme - last.sar) * last.af
            now.trade = do =>
              if parseFloat(data[i][3]) < now.sar then -1 else 0
          else
            now.extreme = do =>
              low = parseFloat data[i][3]
              if low < last.extreme then low else last.extreme
            now.af = do =>
              t = last.af + (now.extreme < last.extreme) * @stepSize
              if t < @maxAF then t else @maxAF
            now.sar = last.sar + (last.extreme - last.sar) * last.af
            now.trade = do =>
              if now.sar < parseFloat(data[i][2]) then 1 else 0
        if now.trade # Trade
          now.position = last.position + now.trade
          assert.equal now.position, 0 # TODO assert
          now.return =
          (1 + last.return) *
          (1 - now.trade * (now.price / now.openPrice - 1)) - 1
          now.openPrice = 0
      else if @cutoff < i # Consider opening a position
        if last.max <= now.price
          now.trade = 1
        else if now.price <= last.min
          now.trade = -1
        if now.trade # Open a position
          now.position = now.trade
          now.extreme = do =>
            if now.trade == 1
              parseFloat data[i][2]
            else
              parseFloat data[i][3]
          now.sar = do =>
            if now.trade == 1
              parseFloat data[i][3]
            else
              parseFloat data[i][2]
          now.openPrice = if now.trade then now.price else 0
      last = now
    return last.return

predict = (data) ->
  day = _.groupBy data, (i) ->
    i[0][..9]
  transaction = new Transaction 4, 8, 0.1, 0.01
  ret = 0
  for i, j of day
    ret = transaction.processDay j, ret
    console.log ret
  return

fs.readFile path.join(__dirname, '../data/stock.fmt'), 'ascii',
(err, data) ->
  if err
    throw err
  raw = JSON.parse(data)
  predict raw
  return
