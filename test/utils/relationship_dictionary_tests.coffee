should = require 'should'
assert = require 'assert'
engine = require '../../bin/engine'

describe "RelationshipDictionary", ->
    dict = null
    beforeEach ->
        dict = new engine.utils.RelationshipDictionary()

    helpers =
        restore_dict: ->
            data = dict.get_save_data()
            dict = new engine.utils.RelationshipDictionary data

    it "gets the value for two keys", ->
        dict.set_value_for_keys 1, 2, "foo"
        dict.get_value_for_keys(1, 2).should.equal "foo"

    it "gets the value for two keys in opposite order as specified", ->
        dict.set_value_for_keys 1, 2, "foo"
        dict.get_value_for_keys(2, 1).should.equal "foo"

    it "does not get another value with the same key", ->
        dict.set_value_for_keys 1, 2, "foo"
        dict.set_value_for_keys 1, 3, "bar"
        dict.get_value_for_keys(1, 2).should.equal "foo"

    describe "restoration", ->
        it "can retrieve a value set before save", ->
            dict.set_value_for_keys 1, 2, "foo"
            helpers.restore_dict()
            dict.get_value_for_keys(1, 2).should.equal "foo"

        it "does not retrieve the wrong value after save", ->
            dict.set_value_for_keys 1, 2, "foo"
            dict.set_value_for_keys 1, 3, "bar"
            helpers.restore_dict()
            dict.get_value_for_keys(1, 2).should.equal "foo"