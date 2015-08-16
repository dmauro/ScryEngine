should = require 'should'
assert = require 'assert'
engine = require '../../bin/engine'

describe "Matrix Array", ->
    array = null
    beforeEach ->
        array = new engine.utils.MatrixArray()

    it "reports height and width", ->
        array.set_value_at -5, 3, true
        array.set_value_at 6, -4, true
        array.width.should.equal 11
        array.height.should.equal 7

    it "reports length", ->
        array.set_value_at -5, 3, true
        array.set_value_at 6, -4, true
        array.length.should.equal 2

    it "gets the correct value at coordinate", ->
        array.set_value_at -5, 3, "foo"
        array.set_value_at 6, -4, "bar"
        array.get_value_at(6, -4).should.equal "bar"
        should.not.exist array.get_value_at(1, 1)

    it "can be property restored", ->
        array.set_value_at -5, 3, "foo"
        array.set_value_at 6, -4, "bar"
        save_data = array.get_save_data()
        array = new engine.utils.MatrixArray save_data
        array.get_value_at(6, -4).should.equal "bar"

    it "can remove items", ->
        array.set_value_at -5, 3, "foo"
        array.set_value_at 6, -4, "bar"
        should.exist array[6]
        array.remove_value_at 6, -4
        should.not.exist array[6]
