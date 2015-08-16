should = require 'should'
assert = require 'assert'
engine = require '../../bin/engine'

describe "Conditions", ->
        it "will only affect something as long as it is active", ->
            class Creature extends engine.things.Thing
                engine.things.define_defaults.call @,
                    dex_mod : 5

            class Grapple extends engine.things.Condition
                engine.things.define_defaults.call @,
                    duration    : Infinity
                _on: ->
                    @registry.get_thing(@target).dex_mod = 0
                _off: ->
                    target = @registry.get_thing(@target)
                    delete target._dex_mod

            thing = new Creature()
            registry = new engine.things.Registry()
            registry.register_thing thing
            thing.dex_mod.should.equal 5
            grapple = new Grapple()
            registry.register_thing grapple
            grapple.apply thing
            thing.dex_mod.should.equal 0
            grapple.remove()
            thing.dex_mod.should.equal 5
            thing._get_listeners("tick").length.should.equal 0
            
        it "can affect target on every tick of that target", ->
            thing = new engine.things.Thing()
            registry = new engine.things.Registry()
            registry.register_thing thing
            thing.hp = 10

            class Burning extends engine.things.Condition
                engine.things.define_defaults.call @,
                    duration    : 3
                _tick: (time) ->
                    @registry.get_thing(@_target).hp -= time * 2

            burning = new Burning()
            registry.register_thing burning
            burning.apply thing
            thing.trigger new engine.events.Event "tick", {time:3}
            thing.hp.should.equal 4

        it "can have custom removal handlers", ->
            target = new engine.things.Thing()
            registry = new engine.things.Registry()
            registry.register_thing target
            target.is_unconscious = false
            
            class Sleeping extends engine.things.Condition
                engine.things.define_defaults.call @,
                    duration            : Infinity
                    canceling_events    : ["damage"]
                _on: ->
                    @registry.get_thing(@_target).is_unconscious = true
                _off: ->
                    @registry.get_thing(@_target).is_unconscious = false

            sleeping = new Sleeping()
            registry.register_thing sleeping
            sleeping.apply target
            target.is_unconscious.should.equal true
            target.trigger new engine.events.Event "damage", {}
            target.is_unconscious.should.equal false

        it "can survive properly through a save and restore", ->
            registry = new engine.things.Registry()
            thing = new engine.things.Thing()
            registry.register_thing thing
            thing.hp = 10

            class engine.things.Burning extends engine.things.Condition
                @cname = "engine.things.Burning"

                engine.things.define_defaults.call @,
                    duration    : 6

                _tick: (time) ->
                    @registry.get_thing(@_target).hp -= time

            burning = new engine.things.Burning()
            registry.register_thing burning
            burning.apply thing
            thing.trigger new engine.events.Event "tick", {time:3}
            thing.hp.should.equal 7

            save_data = JSON.stringify registry.get_save_data()
            registry = new engine.things.Registry save_data
            thing = registry.get_thing thing.id
            burning = registry.get_thing burning.id
            thing.hp.should.equal 7
            thing.trigger new engine.events.Event "tick", {time:3}
            thing.hp.should.equal 4
            thing.trigger new engine.events.Event "tick", {time:3}
            thing.hp.should.equal 4
            burning.remove()

        it "can use the base things property_accessed event to alter a thing's property", ->
            class Creature extends engine.things.Thing
                engine.things.define_defaults.call @,
                    dex_mod : 6
                    other   : 10
            class Grapple extends engine.things.Condition
                engine.things.define_defaults.call @,
                    duration    : Infinity
                property_accessed_handler: (event) ->
                    thing = @registry.get_thing @target
                    thing[event.property_name] = event.value / 2
                _on: ->
                    thing = @registry.get_thing @target
                    thing.bind_property_modifier_handler "dex_mod", @property_accessed_handler, @
                    #thing.on "property_accessed", @property_accessed_handler, @
                _off: ->
                    thing = @registry.get_thing @target
                    thing.unbind_property_modifier_handler "dex_mod", @property_accessed_handler
                    #thing.off "property_accessed", @property_accessed_handler

            registry = new engine.things.Registry()
            thing = new Creature()
            grapple = new Grapple()
            registry.register_thing thing
            registry.register_thing grapple
            grapple.apply thing
            thing.dex_mod.should.equal 3
            thing.other.should.equal 10
            grapple.remove()
            thing.dex_mod.should.equal 6
            thing._get_listeners("property_accessed").length.should.equal 0

        it "will fire a property affected event when we bind a property modifier", (done) ->
            class Creature extends engine.things.Thing
                engine.things.define_defaults.call @,
                    dex_mod : 6
            class Grapple extends engine.things.Condition
                engine.things.define_defaults.call @,
                    duration    : Infinity
                property_accessed_handler: (event) ->
                    thing = @registry.get_thing @target
                    thing[event.property_name] = event.value / 2
                _on: ->
                    thing = @registry.get_thing @target
                    thing.bind_property_modifier_handler "dex_mod", @property_accessed_handler, @
                    #thing.on "property_accessed", @property_accessed_handler, @
                _off: ->
                    thing = @registry.get_thing @target
                    thing.unbind_property_modifier_handler "dex_mod", @property_accessed_handler
                    #thing.off "property_accessed", @property_accessed_handler

            registry = new engine.things.Registry()
            thing = new Creature()
            grapple = new Grapple()
            registry.register_thing thing
            registry.register_thing grapple
            thing.on "property_affected", (event) ->
                event.property.should.equal "dex_mod"
                done()
            grapple.apply thing