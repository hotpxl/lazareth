require 'coffee-script/register'
fs = require 'fs'
path = require 'path'
process = require '../routes/process'
should = require('chai').should()

describe 'Function `process`', ->
  it 'should return as expected', (done) ->
    fs.readFile path.join(__dirname, 'process.output'), 'ascii',
    (err, data) ->
      if err
        throw err
      JSON.parse(data).should.deep.equal process.whatever()
      done()
      return
