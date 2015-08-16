should = require 'should'
assert = require 'assert'
engine = require '../bin/engine'

describe "Alea Random", ->
    alea = null
    beforeEach ->
        alea = new engine.random.Alea()

    it "gives us a random number", ->
        num = alea.random()
        assert.ok 0 <= num < 1

    it "can give us a number in a range", ->
        num = alea.range 1, 10
        assert.ok 1 <= num <= 10

    it "can randomly select from list", ->
        list = ["apple", "orange", "banana"]
        choice = alea.choice list
        assert.ok choice in list

    it "can save and restore itself in the same state it was when saved", ->
        alea.random()
        alea.random()
        alea.random()
        save_data = alea.get_save_data()
        num = alea.random()
        alea = new engine.random.Alea save_data
        alea.random().should.equal num
