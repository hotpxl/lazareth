should = require('chai').should()

describe 'Array', ->
  describe '#indexOf()', ->
    it 'should return -1 when the value is not present', ->
      (-1).should.equal [1, 2, 3].indexOf(5)
      (-1).should.equal [1, 2, 3].indexOf(0)
