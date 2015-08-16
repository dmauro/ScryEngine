should = require 'should'
assert = require 'assert'
engine = require '../../bin/engine'

describe "Registry", ->
    it "can store a thing and retrive something", ->
        thing = new engine.things.Thing()
        registry = new engine.things.Registry()
        registry.register_thing thing
        assert.ok registry.things[0] == thing
        assert.ok thing == registry.get_thing(0)

    it "can cache a thing that is registered", ->
        thing = new engine.things.Thing()
        cache = new engine.Storage()
        registry = new engine.things.Registry null, cache
        registry.register_thing thing
        registry.cache_thing thing._id
        assert.ok registry.things[0] == null

    it "can uncache something that has been cached", ->
        thing = new engine.things.Thing()
        cache = new engine.Storage()
        registry = new engine.things.Registry null, cache
        thing.maxhp = 10
        registry.register_thing thing
        id = thing._id
        registry.cache_thing id
        registry.uncache_thing id
        thing = JSON.stringify thing.get_save_data()
        cache_thing = JSON.stringify registry.get_thing(id).get_save_data()
        assert.ok thing == cache_thing
        
    it "can create save data and be recovered from it", ->
        thing = new engine.things.Thing()
        cache = new engine.Storage()
        registry = new engine.things.Registry null, cache
        registry.register_thing thing
        save_data = JSON.stringify registry.get_save_data()
        registry = new engine.things.Registry JSON.parse save_data, cache
        assert.ok JSON.stringify(thing.get_save_data()) == JSON.stringify(registry.get_thing(0).get_save_data())
