require 'coffee-script/register'
app = require '../app.coffee'
should = require('chai').should()
sw = require 'selenium-webdriver'
driver = new sw.Builder().withCapabilities(sw.Capabilities.chrome())
  .build()
chai = require 'chai'
chai.use require('chai-webdriver')(driver)

describe 'app', ->
  after (done) ->
    app.close()
    done()
  it 'should exist', (done) ->
    should.exist app
    done()
  it 'should have a chart', (done) ->
    driver.get 'http://127.0.0.1:8000'
    chai.expect('#chart_div').to.exist
