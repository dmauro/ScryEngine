should = require 'should'
assert = require 'assert'
engine = require '../bin/engine'

helpers =
    create_game: ->
        game = new engine.Game()
        protagonist = new engine.things.Sentient()
        game.set_protagonist protagonist
        return game

describe "Utils", ->
    describe "Matrix Array", ->
        it "reports height and width", ->
            array = new engine.utils.MatrixArray()
            array.set_value_at -5, 3, true
            array.set_value_at 6, -4, true
            array.width.should.equal 11
            array.height.should.equal 7

        it "reports length", ->
            array = new engine.utils.MatrixArray()
            array.set_value_at -5, 3, true
            array.set_value_at 6, -4, true
            array.length.should.equal 2

        it "gets the correct value at coordinate", ->
            array = new engine.utils.MatrixArray()
            array.set_value_at -5, 3, "foo"
            array.set_value_at 6, -4, "bar"
            array.get_value_at(6, -4).should.equal "bar"
            should.not.exist array.get_value_at(1, 1)

        it "can be property restored", ->
            array = new engine.utils.MatrixArray()
            array.set_value_at -5, 3, "foo"
            array.set_value_at 6, -4, "bar"
            save_data = array.get_save_data()
            array = new engine.utils.MatrixArray save_data
            array.get_value_at(6, -4).should.equal "bar"

        it "can remove items", ->
            array = new engine.utils.MatrixArray()
            array.set_value_at -5, 3, "foo"
            array.set_value_at 6, -4, "bar"
            should.exist array[6]
            array.remove_value_at 6, -4
            should.not.exist array[6]

describe "Game", ->
    describe "Savestates", ->
        it "should be able to save and restore a game", ->
            game = helpers.create_game()
            thing = new engine.things.Base()
            brain = new engine.things.Brain()
            thing.maxhp = 10
            game.registry.register_thing thing
            game.registry.register_thing brain
            game_save = JSON.stringify game._get_save_data()

            # Transfer storage to new game registry
            class Game extends engine.Game
                _create_registry: (data) ->
                    Registry = @constructor_for_name "registry"
                    return new Registry data, game.registry.cache

            new_game = new Game game_save
            new_thing = new_game.registry.get_thing thing.id
            new_thing.maxhp.should.equal 10
            new_game.timekeeper.things[0].time.should.be.a.Number
        it "should be able to restore from a quick-save", ->
            # Make sure both games use same storage object
            cache = new engine.Storage()
            class Game extends engine.Game
                _create_registry: (data) ->
                    return new engine.things.Registry data, cache

            game = new Game()
            protagonist = new engine.things.Sentient()
            game.set_protagonist protagonist

            thing_cached = new engine.things.Base()
            thing_cached.maxhp = 10
            game.registry.register_thing thing_cached
            game.registry.cache_thing thing_cached.id
            thing_uncached = new engine.things.Base()
            thing_uncached.maxhp = 8
            game.registry.register_thing thing_uncached
            quick_save = JSON.stringify game._get_quicksave_data()

            new_game = new Game quick_save
            cached = new_game.registry.get_thing thing_cached.id
            cached.maxhp.should.equal 10
            uncached = new_game.registry.get_thing thing_uncached.id
            uncached.maxhp.should.equal 8
    describe "Timekeeping", ->
        it "can offer turns to things in order", (done) ->
            turn_count = 0

            finish = ->
                game.end()
                thing_1.turns_taken.should.equal 2
                thing_2.turns_taken.should.equal 3
                game.timekeeper.time.should.equal 6
                done()
            class Brain extends engine.things.Brain
                take_turn: (callback) ->
                    if turn_count >= 5
                        finish()
                    else
                        turn_count += 1
                        setTimeout(=>
                            host = @registry.get_thing @host
                            host.turns_taken += 1
                            return callback host.time_for_action
                        , 1)
            thing_1 = new engine.things.Sentient()
            thing_2 = new engine.things.Sentient()
            thing_1.time_for_action = 3
            thing_2.time_for_action = 2
            thing_1.turns_taken = thing_2.turns_taken = 0
            brain_1 = new Brain()
            brain_2 = new Brain()
            # We want to make sure we don't have a Player class
            # blocking the timekeeper loop, so don't use game helper
            game = new engine.Game()
            game.registry.register_thing thing_1
            game.registry.register_thing thing_2
            game.registry.register_thing brain_1
            game.registry.register_thing brain_2
            thing_1.give_sentience brain_1
            thing_2.give_sentience brain_2
            game.timekeeper.start()

        it "in the event of a tie, the thing that went less recently goes first", (done) ->
            class Brain extends engine.things.Brain
                take_turn: (callback) ->
                    setTimeout(=>
                        host = @registry.get_thing @host
                        host.turns_taken += 1
                        return callback host.time_for_action
                    , 10)
            thing_1 = new engine.things.Sentient()
            thing_2 = new engine.things.Sentient()
            thing_1.time_for_action = 1
            thing_2.time_for_action = 2
            thing_1.turns_taken = thing_2.turns_taken = 0
            brain_1 = new Brain()
            brain_2 = new Brain()
            # We want to make sure we don't have a Player class
            # blocking the timekeeper loop, so don't use game helper
            game = new engine.Game()
            game.registry.register_thing thing_1
            game.registry.register_thing thing_2
            game.registry.register_thing brain_1
            game.registry.register_thing brain_2
            thing_1.give_sentience brain_1
            thing_2.give_sentience brain_2
            game.timekeeper.start()
            setTimeout(->
                thing_1.turns_taken.should.equal 1
                game.timekeeper.time.should.equal 0
            , 19)
            setTimeout(->
                thing_2.turns_taken.should.equal 1
                game.timekeeper.time.should.equal 1
            , 29)
            setTimeout(->
                thing_1.turns_taken.should.equal 2
                game.timekeeper.time.should.equal 2
            , 39)
            setTimeout(->
                # Now they are both at 2 seconds, thing_2 should get to go
                thing_2.turns_taken.should.equal 2
                game.timekeeper.time.should.equal 2
                done()
            , 49)

    describe "Protagonist", ->
        it "can have a protagonist", ->
            game = helpers.create_game()
            thing = new engine.things.Sentient()
            game.set_protagonist thing
            game.world.get_protagonist().get_host().x.should.equal 0
            game.world.get_protagonist().get_host().y.should.equal 0

describe "World", ->
    it "can be saved and restored", ->
        game = helpers.create_game()
        thing = new engine.things.Sentient()
        game.set_protagonist thing
        quick_save = JSON.stringify game._get_quicksave_data()
        game = new engine.Game quick_save
        i = 0
        stratum = game.world.strata[0]
        for x, ys of stratum.zones
            for y, zone of ys
                i += 1
                should.exist zone._init_tiles
        i.should.equal 9

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
        save_data = JSON.stringify alea.get_save_data()
        alea.random()
        num = alea.random()
        alea = new engine.random.Alea save_data
        alea.random()
        alea.random().should.equal num


describe "Things", ->
    describe "Base", ->
        it "will wipe a property that is set to the same as a default", ->
            class Humanoid extends engine.things.Base
                engine.things.define_defaults.call @,
                    maxhp : 0

            humanoid = new Humanoid()
            default_value = humanoid._maxhp
            humanoid.maxhp = 5
            assert.ok humanoid.hasOwnProperty "_maxhp"
            humanoid.maxhp = default_value
            assert.ok !humanoid.hasOwnProperty "_maxhp"
        it "can create from serial data", ->
            humanoid = new engine.things.Base()
            humanoid.size = "large"
            data = humanoid.get_save_data()
            new_guy = new engine.things.Base data
            assert.ok JSON.stringify(humanoid.get_save_data()) == JSON.stringify(new_guy.get_save_data())

        describe "Events", ->
            it "can listen for for an event trigger with arguments", (done) ->
                thing = new engine.things.Base()
                _data = {id:Math.random()}
                thing.on "event_name", (event) ->
                    assert.ok event.id == _data.id
                    done()
                thing.trigger new engine.events.Base "event_name", _data
            it "can turn off all event listeners for event", ->
                thing = new engine.things.Base()
                thing.on "event_name", ->
                    throw new Error "We got the event"
                thing.on "event_name", ->
                    throw new Error "We got this one too"
                thing.off "event_name"
                thing.trigger new engine.events.Base "event_name"
            it "can remove only a single listener", (done) ->
                thing = new engine.things.Base()
                listener_1 = ->
                    throw new Error "We got event 1"
                listener_2 = ->
                    done()
                thing.on "event_name", listener_1
                thing.on "event_name", listener_2
                thing.off "event_name", listener_1
                thing.trigger new engine.events.Base "event_name"
            it "can remove all event listeners", ->
                thing = new engine.things.Base()
                thing.on "event_1", ->
                    throw new Error "Event 1 received"
                thing.on "event_2", ->
                    throw new Error "Event 2 received"
                thing.off()
                thing.trigger new engine.events.Base "event_1"
                thing.trigger new engine.events.Base "event_2"

        describe "Polymorph", ->
            it "can turn any non-abstract thing into another", ->
                humanoid = new engine.things.NonAbstract()
                humanoid.maxhp = 10
                giant = humanoid.change_constructor engine.things.Sprite
                assert.ok JSON.stringify(humanoid.get_save_data()) == JSON.stringify(giant.get_save_data())

        describe "Prototype chaining", ->
            it "will trigger all init events throughout the chain", (done) ->
                count = 1
                incr = ->
                    done() if count >= 2
                    count += 1
                class Thing extends engine.things.Base
                    init: ->
                        incr()
                class NewerThing extends Thing
                    init: ->
                        incr()
                instance = new NewerThing()

        describe "Property chaining", ->
            it "will trigger property chains of ancestors and self", (done) ->
                class First extends engine.things.Base
                    @property_chains:
                        foo : ["bar"]
                class Second extends First
                    @property_chains:
                        baz : ["qux"]
                thing = new Second()
                count = 1
                incr = ->
                    if count >= 2
                        done()
                    count += 1
                thing.on "property_affected", (event) ->
                    if event.property in ["bar", "qux"]
                        incr()
                thing.trigger new engine.events.ThingPropertyAffected "foo"
                thing.trigger new engine.events.ThingPropertyAffected "baz"
            it "will do event chaining first in first out", (done) ->
                class First extends engine.things.Base
                    @property_chains:
                        foo : ["bar"]
                    init: ->
                        @count = 0
                    bind_events: ->
                        @on "property_affected", (data) ->
                            @count += 1
                            throw new Error "Incorrect order" unless false or
                            (data.property is "foo" and @count is 1) or
                            (data.property is "bar" and @count is 2) or
                            (data.property is "baz" and @count is 3) or
                            (data.property is "qux" and @count is 4)
                            return done() if @count >= 4 
                class Second extends First
                    @property_chains:
                        baz : ["qux"]
                thing = new Second()
                thing.trigger new engine.events.ThingPropertyAffected "foo"
                thing.trigger new engine.events.ThingPropertyAffected "baz"
            it "will prevent an infinite loop of property chaining", (done) ->
                class First extends engine.things.Base
                    @property_chains:
                        foo : ["bar"]
                class Second extends First
                    @property_chains:
                        bar  : ["foo"]
                thing = new Second()
                count = 1
                thing.on "property_affected", (data) ->
                    if count >= 2
                        done()
                    count += 1
                thing.trigger new engine.events.ThingPropertyAffected "foo"
            it "will do two different events in the proper order", (done) ->
                class First extends engine.things.Base
                    @property_chains:
                        foo : ["bar"]
                    init: ->
                        @count = 0
                    bind_events: ->
                        @on "property_affected", (data) ->
                            @count += 1
                            throw new Error "Incorrect order" unless false or
                            (data.property is "foo" and @count is 1) or
                            (data.property is "bar" and @count is 2) or
                            (data.property is "baz" and @count is 5) or
                            (data.property is "qux" and @count is 6) or
                            (data.property is "qar" and @count is 7)
                            return done() if @count >= 7
                        @on "custom_event", (event) =>
                            @trigger new engine.events.Base "another_event", {}, event
                        @on "another_event", ->
                            @count += 1
                            throw new Error "Incorrect order" unless @count is 4
                class Second extends First
                    @property_chains:
                        baz : ["qux", "qar"]
                    bind_events: ->
                        @on "custom_event", ->
                            @count += 1
                            throw new Error "Incorrect order" unless @count is 3
                thing = new Second()
                thing.trigger new engine.events.ThingPropertyAffected "foo"
                thing.trigger new engine.events.Base "custom_event", {}
                thing.trigger new engine.events.ThingPropertyAffected "baz"
            it "will chain through to all affected properties when one is changed", (done) ->
                class Thing extends engine.things.Base
                    @property_chains:
                        foo : ["bar"]
                    init: ->
                        @count = 0
                    bind_events: ->
                        @on "property_affected", (event) ->
                            @count += 1
                            throw new Error "Incorrect order" unless false or
                            (event.property is "foo" and @count is 1) or
                            (event.property is "bar" and @count is 2)
                            return done() if @count >= 2
                thing = new Thing()
                thing.trigger new engine.events.ThingPropertyChange "foo"

    describe "Conditions", ->
        it "will only affect something as long as it is active", ->
            class Creature extends engine.things.Base
                engine.things.define_defaults.call @,
                    dex_mod : 5

            class Grapple extends engine.things.Condition
                engine.things.define_defaults.call @,
                    length      : Infinity
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
            thing = new engine.things.Base()
            registry = new engine.things.Registry()
            registry.register_thing thing
            thing.hp = 10

            class Burning extends engine.things.Condition
                engine.things.define_defaults.call @,
                    length      : 3
                _tick: (time) ->
                    @registry.get_thing(@_target).hp -= time * 2

            burning = new Burning()
            registry.register_thing burning
            burning.apply thing
            thing.trigger new engine.events.Base "tick", {time:3}
            thing.hp.should.equal 4
        it "can have custom removal handlers", ->
            target = new engine.things.Base()
            registry = new engine.things.Registry()
            registry.register_thing target
            target.is_unconscious = false
            
            class Sleeping extends engine.things.Condition
                engine.things.define_defaults.call @,
                    length              : Infinity
                    canceling_events    : ["damage"]
                _on: ->
                    @registry.get_thing(@_target).is_unconscious = true
                _off: ->
                    @registry.get_thing(@_target).is_unconscious = false

            sleeping = new Sleeping()
            registry.register_thing sleeping
            sleeping.apply target
            target.is_unconscious.should.equal true
            target.trigger new engine.events.Base "damage", {}
            target.is_unconscious.should.equal false
        it "can survive properly through a save and restore", ->
            game = helpers.create_game()
            thing = new engine.things.Base()
            game.registry.register_thing thing
            thing.hp = 10

            class engine.things.Burning extends engine.things.Condition
                @cname = "engine.things.Burning"

                engine.things.define_defaults.call @,
                    length      : 6

                _tick: (time) ->
                    @registry.get_thing(@_target).hp -= time

            burning = new engine.things.Burning()
            game.registry.register_thing burning
            burning.apply thing
            thing.trigger new engine.events.Base "tick", {time:3}
            thing.hp.should.equal 7

            save_data = JSON.stringify game._get_save_data()
            game = new engine.Game save_data
            thing = game.registry.get_thing thing.id
            burning = game.registry.get_thing burning.id
            thing.hp.should.equal 7
            thing.trigger new engine.events.Base "tick", {time:3}
            thing.hp.should.equal 4
            thing.trigger new engine.events.Base "tick", {time:3}
            thing.hp.should.equal 4
            burning.remove()
        it "can use the base things property_accessed event to alter a thing's property", ->
            class Creature extends engine.things.Base
                engine.things.define_defaults.call @,
                    dex_mod : 6
                    other   : 10
            class Grapple extends engine.things.Condition
                engine.things.define_defaults.call @,
                    length  : Infinity
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
            class Creature extends engine.things.Base
                engine.things.define_defaults.call @,
                    dex_mod : 6
            class Grapple extends engine.things.Condition
                engine.things.define_defaults.call @,
                    length  : Infinity
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

        it "will immediately fade if they have no duration", ->
            class FootStep extends engine.things.Effect
                engine.things.define_defaults.call @,
                    level       : 1
                    type        : "sound"

            registry = new engine.things.Registry()
            thing = new engine.things.Sprite()
            footstep = new FootStep()
            registry.register_thing thing
            registry.register_thing footstep
            thing.sound_effects_level.should.equal 0
            footstep.apply thing
            thing.sound_effects_level.should.equal 0

    describe "Events", ->
        it "others can interrupt with their own events", (done) ->
            runner = null
            attacker = null
            was_hit = false
            class Runner extends engine.things.Base
                bind_events: ->
                    @on "scared", (event) =>
                        attacker.trigger new engine.events.Base "offer_aoo", {}, event
                        @trigger new engine.events.Base "flee", {}, event
                    @on "hit", ->
                        was_hit = true
                    @on "flee", ->
                        assert.ok was_hit
                        done()
            class Attacker extends engine.things.Base
                bind_events: ->
                    @on "offer_aoo", (event) ->
                        runner.trigger new engine.events.Base "hit", {}, event
            runner = new Runner()
            attacker = new Attacker()
            runner.trigger new engine.events.Base "scared"

        it "will allow for a callback to wait for player input for something like an attack of opportunity", (done) ->
            defender = null
            attacker = null
            attacker_2 = null

            class Creature extends engine.things.Base
                init: ->
                    @attack_count = 0

                bind_events: ->
                    @on "provoke_aoo", (event, callback) =>
                        setTimeout(->
                            event.subject.trigger new engine.events.Base "attack", {subject:event.subject}, event
                            callback()
                        , 10) # Arbitrary wait to simulate wait for player input
                        return false
                    @on "attack", (event) =>
                        if @ is event.subject
                            @attack_count += 1
                    @on "run_away", (event) =>
                        provoke_event = new engine.events.Base "provoke_aoo", {subject:@}, event
                        attacker.trigger provoke_event, =>
                            attacker_2.trigger provoke_event, =>
                                @trigger new engine.events.Base "ran_away", {}, event
                    @on "ran_away", (event) =>
                        @attack_count.should.equal 2
                        done()

            defender = new Creature()
            attacker = new Creature()
            attacker_2 = new Creature()

            defender = defender.trigger new engine.events.Base "run_away"

        it "will halt triggering of an event if a handler returns true", ->
            class Creature extends engine.things.Base
                init: ->
                    @hp = 10
                bind_events: ->
                    @on "damage", (event) =>
                        @hp -= event.damage

            class ElectricProof extends Creature
                bind_events: ->
                    @on "damage", (event) =>
                        return true if event.type is "electric"

            electric_damage = new engine.events.Base "damage", {damage:5, type:"electric"}
            creature_1 = new ElectricProof()
            creature_2 = new Creature()
            creature_1.trigger electric_damage
            creature_1.hp.should.equal 10
            creature_2.trigger electric_damage
            creature_2.hp.should.equal 5

        it "will halt triggering of an event if a callback returns true", (done) ->
            class Creature extends engine.things.Base
                init: ->
                    @hp = 10
                bind_events: ->
                    @on "damage", (event, callback) =>
                        setTimeout(=>
                            @hp -= event.damage
                            callback()
                        , 10) # Just for the hell of it
                        return false

            class ElectricProof extends Creature
                bind_events: ->
                    @on "damage", (event, callback) =>
                        setTimeout(->
                            callback event.type is "electric"
                        , 10) # arbitrary delay
                        return false

            electric_damage = new engine.events.Base "damage", {damage:5, type:"electric"}
            creature_1 = new ElectricProof()
            creature_2 = new Creature()
            creature_1.trigger electric_damage, ->
                creature_1.hp.should.equal 10
                creature_2.trigger electric_damage, ->
                    creature_2.hp.should.equal 5
                    done()
        it "will remove the event if the last handler is removed", ->
            thing = new engine.things.Base()
            handler = ->
            thing.on "custom_event", handler
            thing.off "custom_event", handler
            assert.ok thing._get_events()["custom_event"] is undefined

    describe "Registry", ->
        it "can store a thing and retrive something", ->
            thing = new engine.things.Base()
            registry = new engine.things.Registry()
            registry.register_thing thing
            assert.ok registry.things[0] == thing
            assert.ok thing == registry.get_thing(0)
        it "can cache a thing that is registered", ->
            thing = new engine.things.Base()
            cache = new engine.Storage()
            registry = new engine.things.Registry null, cache
            registry.register_thing thing
            registry.cache_thing thing._id
            assert.ok registry.things[0] == null
        it "can uncache something that has been cached", ->
            thing = new engine.things.Base()
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
            thing = new engine.things.Base()
            cache = new engine.Storage()
            registry = new engine.things.Registry null, cache
            registry.register_thing thing
            save_data = JSON.stringify registry.get_save_data()
            registry = new engine.things.Registry JSON.parse save_data, cache
            assert.ok JSON.stringify(thing.get_save_data()) == JSON.stringify(registry.get_thing(0).get_save_data())

    describe "Message Console", ->
        it "handles variables properly", ->
            game = helpers.create_game()
            thing = game.registry.get_thing 0
            thing.registry.display_message_to_console "Q: %@ + %@ = %@", 2, 2, "what?"
            game.message_console.messages[0].should.equal "Q: 2 + 2 = what?"

    describe "Action Manager", ->
        it "calls the do method of an action", ->
            registry = new engine.things.Registry()
            brain = new engine.things.Brain()
            actor = new engine.things.Sentient()
            registry.register_thing brain
            registry.register_thing actor
            actor.give_sentience brain
            action_manager = new engine.actions.ActionManager()
            count = 0
            class TestAction extends engine.actions.Base
                do: ->
                    count += 1
            action_manager.do_action brain, TestAction
            count.should.equal 1

        it "gets the correct time to complete an action", ->
            registry = new engine.things.Registry()
            brain = new engine.things.Brain()
            actor = new engine.things.Sentient()
            registry.register_thing brain
            registry.register_thing actor
            actor.give_sentience brain
            action_manager = new engine.actions.ActionManager()
            class TestAction extends engine.actions.Base
                _get_time_to_complete: ->
                    return 3
            action_manager.do_action brain, TestAction, {}, (time) ->
                time.should.equal 3
