should = require 'should'
assert = require 'assert'
engine = require '../../bin/engine'

describe "Effects", ->
    it "appropriately affects the target thing's level", ->
        class Cough extends engine.things.Effect
            engine.things.define_defaults.call @,
                level       : 4
                type        : "sound"
                duration    : true

        registry = new engine.things.Registry()
        thing = new engine.things.Sprite()
        cough = new Cough()
        registry.register_thing thing
        registry.register_thing cough
        thing.sound_effects_level.should.equal 0
        cough.apply thing
        thing.sound_effects_level.should.equal 4
        cough.remove()
        registry.unregister_thing cough
        thing.sound_effects_level.should.equal 0

    it "will immediately fade if they are immediate", ->
        class FootStep extends engine.things.Effect
            engine.things.define_defaults.call @,
                level           : 1
                type            : "sound"
                is_immediate    : true

        registry = new engine.things.Registry()
        thing = new engine.things.Sprite()
        footstep = new FootStep()
        registry.register_thing thing
        registry.register_thing footstep
        thing.sound_effects_level.should.equal 0
        footstep.apply thing
        thing.sound_effects_level.should.equal 0
