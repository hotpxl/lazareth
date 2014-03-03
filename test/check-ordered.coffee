fs = require 'fs'
path = require 'path'
moment = require 'moment'
should = require('chai').should()

checkOrdered = (list) ->
  for i in [0..list.length - 1]
    if 0 < list[i].diff list[i + 1]
      return false
  return true

describe 'Orginial data', ->
  describe 'time in cu-intraday.fmt', ->
    it 'should be sorted', (done) ->
      fs.readFile path.join(__dirname, '../data/cu-intraday.fmt'), 'ascii',
      (err, data) ->
        if err
          throw err
        raw = JSON.parse data
        time = moment i[0] for i in raw
        checkOrdered(time).should.equal true
        done()
        return
  describe 'time in stock.fmt', ->
    it 'should be sorted', (done) ->
      fs.readFile path.join(__dirname, '../data/stock.fmt'), 'ascii',
      (err, data) ->
        if err
          throw err
        raw = JSON.parse data
        time = moment i[0] for i in raw
        checkOrdered(time).should.equal true
        done()
        return
