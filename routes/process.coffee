fs = require 'fs'
path = require 'path'
moment = require 'moment'

class Transaction

  constructor: (@rollback, @cutoff, @maxAF, @stepSize) ->
    @time = 0
    @rollbackMax = 0
    @rollbackMin = 0
    @return = 0
    @sar = 0
    @extreme = 0
    @position = 0
    @lastTrade = 0
    if @cutoff < @rollback
      throw new Error 'Rollback larger than cutoff'

  processDay: (data) ->
    now =
      trade: 0
      position: 0
      af: 0
      extreme: 0
      sar: 0
      price: 0
    last =
      trade: 0
      position: 0
      af: 0
    # Data here should be of one day
    for i in [0..data.length - 1]
      if last.position # SAR
        if i == data.length - 1 # Force cover at the end of day
          now.trade = -last.position
        else
          now.extreme = if 0 < (now.price - last.extreme) * last.position then now.price else last.extreme
          now.af = do ->
            t = last.af + (now.extreme - last.extreme) * @stepSize
            if t < @maxAF then t else @maxAF
          now.sar = last.sar + (now.extreme - last.sar) * now.af
          trade = if 0 < (now.sar - now.price) * last.position then -1 else 1

  # updateOnce: (data) ->
  #   if data.length <= @time
  #     throw new Error 'Time overflow'
  #   trade = 0
  #   if @time && @position # Check position
  #     if moment(data[@time][0]).dayOfYear() != moment(data[@time - 1][0]).dayOfYear() || @time == data.length - 1 # Force cover at the end of the day
  #       trade = -@position
  #     else # Use SAR technique
  #       if @position == 1
  #         lastPrice = parseInt(data[@time - 1])
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
  transaction = new Transaction 2, 15, 0.02, 0.1, 0.01
  return

fs.readFile path.join(__dirname, '../data/CU.intraday.csv.fmt'), 'ascii', (err, data) ->
  if err
    throw err
  raw = JSON.parse(data)[-300..]
  predict raw
  return
