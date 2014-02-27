fs = require 'fs'
path = require 'path'
moment = require 'moment'
# should = require('chai').should()
_ = require 'underscore'

# TODO pass between function a status object? Or calculate everyone's own status

openPositionStrategyForSessionFactory = (rollback, cutoff) ->
  extreme = do ->
    max = undefined
    min = undefined
    (n) ->
      ret = [max, min]
      max = if max < n or max == undefined then n else max
      min = if n < min or min == undefined then n else min
      ret
  rollbackQueue = new Array rollback
  (price, timeIndex) ->
    rollbackQueue.push price
    [max, min] = extreme rollbackQueue.shift()
    if cutoff < timeIndex
      if max <= price
        1
      else if price <= min
        -1
    else
      0

class Transaction

  constructor: (@rollback, @cutoff, @maxAF, @stepSize) ->
    if @cutoff < @rollback
      throw new Error 'Rollback larger than cutoff'

  processDay: (data, ret) ->
    retList = []
    last =
      trade: 0
      position: 0
      extreme: 0
      af: 0
      sar: 0
      price: 0
      openPrice: 0
      return: ret
    # Data here should be of one day
    openPositionStrategy = openPositionStrategyForSessionFactory(@rollback, @cutoff)
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
      openPosition = openPositionStrategy now.price, i
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
          now.return =
          (1 + last.return) *
          (1 - now.trade * (now.price / now.openPrice - 1)) - 1
          now.openPrice = 0
      else # Consider opening a position
        now.trade = openPosition
        if now.trade # Open a position
          now.position = now.trade
          now.extreme = now.price
          now.sar = now.price
          now.openPrice = if now.trade then now.price else 0
      last = now
      retList.push last.return
    return retList

predict = (data) ->
  a = _.groupBy data, (i) ->
    i[0][..9]
  transaction = new Transaction 4, 8, 0.1, 0.01
  currentReturn = 0
  retList = []
  for i, j of a
    retList = retList.concat transaction.processDay(j, currentReturn)
    currentReturn = retList[retList.length - 1]
  return retList

exports.whatever = ->
  data = fs.readFileSync path.join(__dirname, '../data/stock.fmt'), 'ascii'
  raw = JSON.parse data
  result = predict raw
  ret = [['Time', 'Close', 'Return']]
  for i in [0..raw.length - 1] by Math.floor(raw.length / 400)
    ret.push [raw[i][0], raw[i][1], result[i]]
  return ret
