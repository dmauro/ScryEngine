assert = require 'assert'
engine = require '../bin/engine'

describe "Storage", ->

    storage = null
    key = "my_key"

    beforeEach ->
        storage = new engine.Storage

    it "can set an item", ->
        item = {}
        storage.set_item key, item
        assert.equal storage.data[key], item

    it "can get an item", ->
        item = {}
        storage.set_item key, item
        assert.equal storage.get_item(key), item

    it "can remove an item", ->
        item = {}
        storage.set_item key, item
        storage.remove_item key
        assert.equal storage.get_item(key), undefined
