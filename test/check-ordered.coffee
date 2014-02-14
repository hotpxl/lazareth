fs = require 'fs'
path = require 'path'
moment = require 'moment'
should = require 'should'

checkOrdered = (list) ->
  for i in [0..list.length - 1]
    if 0 < list[i].diff list[i + 1]
      return false
  return true

describe 'Orginial data', ->
  describe 'time in CU.intraday.csv.fmt', ->
    it 'should be sorted', (done) ->
      fs.readFile path.join(__dirname, '../data/CU.intraday.csv.fmt'),'ascii',
      (err, data) ->
        if err
          throw err
        raw = JSON.parse data
        time = moment i[0] for i in raw
        checkOrdered(time).should.be.exactly true
        done()
        return
  describe 'time in stock.csv.fmt', ->
    it 'should be sorted', (done) ->
      fs.readFile path.join(__dirname, '../data/stock.csv.fmt'),'ascii',
      (err, data) ->
        if err
          throw err
        raw = JSON.parse data
        time = moment i[0] for i in raw
        checkOrdered(time).should.be.exactly true
        done()
        return
