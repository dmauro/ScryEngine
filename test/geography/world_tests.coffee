should = require 'should'
assert = require 'assert'
engine = require '../../bin/engine'

describe "World", ->
    registry = null
    world = null
    host = null
    player = null
    seed = 1

    helpers =
        restore_world_from_save: ->
            data = world.get_save_data()
            world.remove()
            world = null
            world = new engine.geography.World data
            world.bind_to_registry registry
            world.protagonist_ready player
            world.start()

    beforeEach ->
        registry = new engine.things.Registry()
        world = new engine.geography.World()
        world.bind_to_registry registry
        host = new engine.things.Sentient()
        player = new engine.things.Player()
        registry.register_thing host
        registry.register_thing player
        host.give_sentience player
        world.init player, seed
        world.protagonist_ready player
        world.start()

    it "creates strata at the host's level", ->
        assert.ok world.strata[host.z] instanceof engine.geography.Stratum

    it "will not create strata immediately above and below host", ->
        should.not.exist world.strata[host.z + 1]
        should.not.exist world.strata[host.z - 1]

    it "will create a new strata when host changes z level", ->
        host.move_to host.x, host.y, host.z + 1
        assert.ok world.strata[host.z] instanceof engine.geography.Stratum

    it "has the correct protagonist id", ->
        world.protagonist.should.equal player.id

    it "gets the correct protagonist from registry", ->
        registry.get_thing(world.protagonist).should.equal player

    # TODO: Should we be caching strata

    describe "restoration", ->
        it "perf test", ->
            data = world.get_save_data()
            world.remove()
            world = null
            world = new engine.geography.World data
            world.bind_to_registry registry
            world.protagonist_ready player
            world.start()

        it "has strata at host's level", ->
            helpers.restore_world_from_save()
            assert.ok world.strata[host.z] instanceof engine.geography.Stratum

        it "continues tracking host", ->
            helpers.restore_world_from_save()
            host.move_to host.x, host.y, host.z + 1
            assert.ok world.strata[host.z] instanceof engine.geography.Stratum
