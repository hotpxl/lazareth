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
      max: parseFloat data[0][1]
      min: parseFloat data[0][1]
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
          t = parseFloat data[i - @rollback][1]
          now.max = if last.max < t then t else last.max
          now.min = if t < last.min then t else last.min
      if last.position # SAR
        if i == data.length - 1 # Force cover at the end of day
          now.trade = -last.position
        else
          now.extreme = if 0 < (now.price - last.extreme) * last.position
          then now.price else last.extreme
          now.af = do =>
            t = last.af + (now.extreme isnt last.extreme) * @stepSize
            if t < @maxAF then t else @maxAF
          now.sar = last.sar + (now.extreme - last.sar) * now.af
          now.trade = if 0 < (now.sar - now.price) * last.position
          then -last.position else 0
        if now.trade # Trade
          now.position = last.position + now.trade
          assert.equal now.position, 0 # TODO assert
          now.return =
          (1 + last.return) *
          (1 - now.trade * (now.openPrice / now.price - 1)) - 1
          now.openPrice = 0
      else if @cutoff < i # Consider opening a position
        if last.max <= now.price
          now.trade = 1
        else if now.price <= last.min
          now.trade = -1
        if now.trade # Open a position
          now.position = now.trade
          now.extreme = now.price
          now.sar = now.price
          now.openPrice = if now.trade then now.price else 0
      last = now
    console.log last.return
    return last.return


# updateOnce: (data) ->
#   if data.length <= @time
#     throw new Error 'Time overflow'
#   trade = 0
#   if @time && @position # Check position
#     if moment(data[@time][0]).dayOfYear() != moment(data[@time - 1][0]).dayOfYear() || @time == data.length - 1 # Force cover at the end of the day
#       trade = -@position
#     else # Use SAR technique
#       if @position == 1
#         lastPrice = parseFloat(data[@time - 1])
#         if @lastTrade
#           @sar = lastPrice * 0.9 # Should be high and low
#           @extreme = lastPrice * 1.1
#           @af = 0
#         else
#           @af = @af + (@extreme < lastPrice) * @stepSize
#           if @maxAF < @af
#             @af = @maxAF
#           @extreme = if @extreme < lastPrice * 1.1 then lastPrice * 1.1 else @extreme
#           @sar = @sar + (@extreme - @sar) * @af
#         if data[@time - 1] < @sar # Stop and reverse
#           trade = -1
predict = (data) ->
  a = _.groupBy data, (i) ->
    i[0][..9]
  transaction = new Transaction 2, 15, 0.1, 0.01
  ret = 0
  for i, j of a
    ret = transaction.processDay j, ret
  return

fs.readFile path.join(__dirname, '../data/stock.csv.fmt'), 'ascii',
(err, data) ->
  if err
    throw err
  raw = JSON.parse(data)
  predict raw
  return
