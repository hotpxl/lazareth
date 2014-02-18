require 'coffee-script/register'
app = require '../app.coffee'
should = require('chai').should()

describe 'app', ->
  after (done) ->
    app.close()
    done()
  it 'should exist', (done) ->
    should.exist app
    done()
