should = require 'should'
assert = require 'assert'
engine = require '../bin/engine'

registry = null
manager = null
sprite = null

helpers =
    setup_manager: ->
        registry = new engine.things.Registry()
        manager = new engine.perception.SpriteManager()
        manager.bind_to_registry registry

    restore_manager: ->
        data = manager.get_save_data()
        manager = new engine.perception.SpriteManager data
        manager.bind_to_registry registry

describe "Sprite Manager", ->
    beforeEach ->
        helpers.setup_manager()

    it "adds sprite to array", ->
        sprite = new engine.things.Sprite()
        registry.register_thing sprite
        manager.sprites[0].should.be.equal sprite

    it "adds position entry for sprite when added", ->
        sprite = new engine.things.Sprite()
        registry.register_thing sprite
        manager.positions[sprite.id].should.exist

    it "adds correct position entry for sprite", ->
        sprite = new engine.things.Sprite()
        sprite.x = 1
        sprite.y = 1
        registry.register_thing sprite
        manager.positions[sprite.id][0].should.equal sprite.x
        manager.positions[sprite.id][1].should.equal sprite.y

    it "removes a sprite from array when unregistered", ->
        sprite = new engine.things.Sprite()
        registry.register_thing sprite
        registry.unregister_thing sprite
        manager.sprites.length.should.equal 0

    it "removes a sprite from array when cached", ->
        sprite = new engine.things.Sprite()
        registry.register_thing sprite
        registry.cache_thing sprite.id
        manager.sprites.length.should.equal 0

    it "removes positions when removing", ->
        sprite = new engine.things.Sprite()
        registry.register_thing sprite
        registry.unregister_thing sprite
        manager.positions[sprite.id].should.exist

    describe "restoration", ->
        it "still has the sprite after restore", ->
            sprite = new engine.things.Sprite()
            registry.register_thing sprite
            debugger
            helpers.restore_manager()
            manager.sprites[0].should.be.equal sprite

        it "has the position after restore", ->
            sprite = new engine.things.Sprite()
            sprite.x = 1
            sprite.y = 1
            registry.register_thing sprite
            debugger
            helpers.restore_manager()
            manager.sprites[0].should.be.equal sprite

    describe "distances", ->
        it "can get los distance between two sprites", ->
            sprite1 = new engine.things.Sprite()
            sprite1.x = 1
            sprite1.y = 1
            registry.register_thing sprite1
            sprite2 = new engine.things.Sprite()
            sprite2.x = 2
            sprite2.y = 2
            registry.register_thing sprite2
            los_distance = manager.get_los_distance_between sprite1.id, sprite2.id
            los_distance.should.be.equal Math.sqrt 2

        # TODO: Distance and pathfinding stuff.
        # How does the pathfinding know about the world? Does this query
        # pathfinding for distances, or is it given them?
