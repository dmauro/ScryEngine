should = require 'should'
assert = require 'assert'
engine = require '../bin/engine'

registry = null
manager = null
brain = null

filter = null
sprite = null

helpers =
    setup_manager: ->
        registry = new engine.things.Registry()
        manager = new engine.perception.PerceptionManager()
        manager.bind_to_registry registry
        brain = new engine.things.Brain()
        registry.register_thing brain

    restore_manager: ->
        data = manager.get_save_data()
        manager = new engine.perception.PerceptionManager(data)

    setup_filter: ->
        registry = new engine.things.Registry()
        filter = new engine.perception.SpritePerceptionLayer()
        sprite = new engine.things.Sprite()
        registry.register_thing sprite
        filter.set_sprite sprite

    restore_filter: ->
        data = filter.get_save_data()
        filter = new engine.perception.SpritePerceptionLayer(data)
        filter.bind_to_registry registry

describe "Perception", ->
    describe "PerceptionManager", ->
        beforeEach ->
            helpers.setup_manager()

        it "saves the brain id for each brain", ->
            manager.brain_ids.length.should.equal 1

        it "creates filters for each brain", ->
            assert.ok manager.filters[brain.id] instanceof engine.perception.PerceptionFilter

        it "creates a perception layer for a new sprite", ->
            sprite = new engine.things.Sprite()
            registry.register_thing sprite
            assert.ok manager.perception_layer_arrays[brain.id][0] instanceof engine.perception.SpritePerceptionLayer

        it "creates a perception layer for each sprite when a new brain is registered", ->
            sprite = new engine.things.Sprite()
            registry.register_thing sprite
            new_brain = new engine.things.Brain()
            registry.register_thing new_brain
            manager.perception_layer_arrays[new_brain.id].length.should.equal 1

        it "removes perception layers when sprites are unregistered", ->
            sprite = new engine.things.Sprite()
            registry.register_thing sprite
            registry.unregister_thing sprite
            manager.perception_layer_arrays[brain.id].length.should.equal 0

        it "removes perception layers when sprites are cached", ->
            sprite = new engine.things.Sprite()
            registry.register_thing sprite
            registry.cache_thing sprite.id
            manager.perception_layer_arrays[brain.id].length.should.equal 0

        it "removes brain id when brain is unregistered", ->
            registry.unregister_thing brain
            manager.brain_ids.length.should.equal 0

        it "removes brain id when brain is cached", ->
            registry.cache_thing brain.id
            manager.brain_ids.length.should.equal 0

        it "removes brain filter when brain is unregisterd", ->
            registry.unregister_thing brain
            assert.ok manager.filters[brain.id] == undefined

        it "removes brain filter when brain is cached", ->
            registry.cache_thing brain.id
            assert.ok manager.filters[brain.id] == undefined

        it "removed perception layers when brain is unregistered", ->
            sprite = new engine.things.Sprite()
            registry.register_thing sprite
            registry.unregister_thing brain
            assert.ok manager.perception_layer_arrays[brain.id] == undefined

        it "removed perception layers when brain is cached", ->
            sprite = new engine.things.Sprite()
            registry.register_thing sprite
            registry.cache_thing brain.id
            assert.ok manager.perception_layer_arrays[brain.id] == undefined

        describe "restoration", ->
            it "restores brain ids after save", ->
                helpers.restore_manager()
                manager.brain_ids[0].should.equal brain.id

            it "restores filters after save", ->
                helpers.restore_manager()
                assert.ok manager.filters[brain.id] instanceof engine.perception.PerceptionFilter

            it "restores perception layers for sprites", ->
                sprite = new engine.things.Sprite()
                registry.register_thing sprite
                helpers.restore_manager()
                assert.ok manager.perception_layer_arrays[brain.id][0] instanceof engine.perception.SpritePerceptionLayer

    describe "PerceptionFilter", ->
        beforeEach ->
            helpers.setup_filter()

        it "starts with levels at 0", ->
            for type in ["visual", "sound", "smell", "touch"]
                filter.presence_levels[type].should.equal 0

        it "affects filter levels when sprite is affected", ->
            effect = new engine.things.Effect()
            effect.type = "visual"
            effect.level = 5
            registry.register_thing effect
            effect.apply sprite
            filter.presence_levels[effect.type].should.equal effect.level

        it "remembers the spike in levels even after they've gone", ->
            effect = new engine.things.Effect()
            effect.type = "visual"
            effect.level = 5
            effect.is_immediate = true
            registry.register_thing effect
            effect.apply sprite
            sprite.visual_effects_level.should.equal 0
            filter.presence_levels[effect.type].should.equal effect.level

        it "uses existing sprite levels when created", ->
            registry = new engine.things.Registry()
            filter = new engine.perception.SpritePerceptionLayer()
            sprite = new engine.things.Sprite()
            registry.register_thing sprite
            effect = new engine.things.Effect()
            effect.type = "visual"
            effect.level = 5
            registry.register_thing effect
            effect.apply sprite
            filter.set_sprite sprite
            effect.remove()
            filter.presence_levels[effect.type].should.equal effect.level

        describe "restoration", ->
            it "saves presence levels", ->
                effect = new engine.things.Effect()
                effect.type = "visual"
                effect.level = 5
                effect.is_immediate = true
                registry.register_thing effect
                effect.apply sprite
                sprite.visual_effects_level.should.equal 0
                helpers.restore_filter()
                filter.presence_levels[effect.type].should.equal effect.level

            it "is still listening after restore", ->
                helpers.restore_filter()
                effect = new engine.things.Effect()
                effect.type = "visual"
                effect.level = 5
                registry.register_thing effect
                effect.apply sprite
                filter.presence_levels[effect.type].should.equal effect.level
