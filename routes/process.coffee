fs = require 'fs'
path = require 'path'
moment = require 'moment'
_ = require 'underscore'

openPositionStrategyForSessionFactory = (rollback, cutoff) ->
  extreme = do ->
    max = undefined
    min = undefined
    (n) ->
      ret = [max, min]
      max = if max < n or max == undefined then n else max
      min = if n < min or min == undefined then n else min
      ret
  rollbackQueue = new Array(rollback)
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

closePositionStrategyForSessionFactory = (maxAF, stepSize, pos, price) ->
  last =
    position: pos
    extreme: price
    af: 0
    sar: price
  (price) ->
    now =
      position: last.position
      extreme: if 0 < (price - last.extreme) * last.position
      then price else last.extreme
      af: 0
      sar: 0
    now.af = do =>
      t = last.af + (now.extreme isnt last.extreme) * stepSize
      if t < maxAF then t else maxAF
    now.sar = last.sar + (now.extreme - last.sar) * now.af
    last = now
    now.sar
    if 0 < (now.sar - price) * last.position
      -last.position
    else
      0

class Transaction

  constructor: (rollback, cutoff, maxAF, stepSize) ->
    @rollback = parseInt rollback
    @cutoff = parseInt cutoff
    @maxAF = parseFloat maxAF
    @stepSize = parseFloat stepSize
    if isNaN(@rollback) or isNaN(@cutoff) or isNaN(@maxAF) or isNaN(@stepSize) or @cutoff < @rollback
      throw new Error 'Rollback larger than cutoff'

  processDay: (data, ret) ->
    retList = []
    last =
      trade: 0
      position: 0
      price: 0
      openPrice: 0
      return: ret
    # Data here should be of one day
    openPositionStrategy = openPositionStrategyForSessionFactory @rollback, @cutoff
    for i in [0..data.length - 1]
      now =
        trade: 0
        position: last.position
        price: parseFloat data[i][1]
        openPrice: last.openPrice
        return: last.return
      openPosition = openPositionStrategy now.price, i
      if last.position # SAR
        if i == data.length - 1 # Force cover at the end of day
          now.trade = -last.position
        else
          now.trade = closePositionStrategy now.price
        if now.trade # Trade
          now.position = last.position + now.trade
          now.return =
          last.return *
          (1 - now.trade * (now.price / now.openPrice - 1))
          now.openPrice = 0
      else # Consider opening a position
        now.trade = openPosition
        if now.trade # Open a position
          now.position = now.trade
          closePositionStrategy = closePositionStrategyForSessionFactory @maxAF, @stepSize, now.trade, now.price
          now.openPrice = if now.trade then now.price else 0
      last = now
      retList.push last.return
    return retList

maxDrawback = (data) ->
  len = data.length
  curMin = data[len - 1]
  drawback = []
  for i in [data.length - 2..0]
    curMin = if data[i] < curMin then data[i] else curMin
    drawback.push (data[i] - curMin) / data[i]
  _.max drawback

# sharpeRatio = (raw, data) ->
#   # TODO Not done
#   time = (moment(i[0]) for i in raw)
#   timeDiff = _.map time, (i) ->
#     i.diff time[0], 'years', true
#   # Calculate return for every time point
#   ret = []
#   for i in [0..data.length - 1]
#     if timeDiff[i] == 0
#       ret.push 0
#     else
#       ret.push Math.log(data[i]) / timeDiff[i]
#   sum = _.reduce ret, (a, b) ->
#     a + b
#   mean = sum / data.length
#   console.log mean

predict = (data, param) ->
  a = _.groupBy data, (i) ->
    i[0][..9]
  # transaction = new Transaction 4, 8, 0.1, 0.01
  transaction = new Transaction(param.rollback, param.cutoff, param.maxAF, param.stepSize)
  currentReturn = 1
  retList = []
  for i, j of a
    retList = retList.concat transaction.processDay(j, currentReturn)
    currentReturn = retList[retList.length - 1]
  return retList

exports.run = (param) ->
  data = fs.readFileSync path.join(__dirname, '../data/stock.fmt'), 'ascii'
  raw = JSON.parse data
  try
    result = predict raw, param
  catch err
    return status: -1, err: 'Invalid parameter'
  ret = []
  for i in [0..raw.length - 1] by Math.floor(raw.length / 400)
    ret.push [raw[i][0], raw[i][1], result[i]]
  ret.unshift ['Time', 'Close', 'Return']
  drawback = maxDrawback result
  return status: 0, plot: ret, maxDrawback: drawback
