should = require 'should'
assert = require 'assert'
engine = require '../../bin/engine'

describe "Events", ->
    it "others can interrupt with their own events", (done) ->
        runner = null
        attacker = null
        was_hit = false
        class Runner extends engine.things.Thing
            bind_events: ->
                @on "scared", (event) =>
                    attacker.trigger new engine.events.Event "offer_aoo", {}, event
                    @trigger new engine.events.Event "flee", {}, event
                @on "hit", ->
                    was_hit = true
                @on "flee", ->
                    assert.ok was_hit
                    done()
        class Attacker extends engine.things.Thing
            bind_events: ->
                @on "offer_aoo", (event) ->
                    runner.trigger new engine.events.Event "hit", {}, event
        runner = new Runner()
        attacker = new Attacker()
        runner.trigger new engine.events.Event "scared"

    it "will allow for a callback to wait for player input for something like an attack of opportunity", (done) ->
        defender = null
        attacker = null
        attacker_2 = null

        class Creature extends engine.things.Thing
            init: ->
                @attack_count = 0

            bind_events: ->
                @on "provoke_aoo", (event, callback) =>
                    setTimeout(->
                        event.subject.trigger new engine.events.Event "attack", {subject:event.subject}, event
                        callback()
                    , 10) # Arbitrary wait to simulate wait for player input
                    return false
                @on "attack", (event) =>
                    if @ is event.subject
                        @attack_count += 1
                @on "run_away", (event) =>
                    provoke_event = new engine.events.Event "provoke_aoo", {subject:@}, event
                    attacker.trigger provoke_event, =>
                        attacker_2.trigger provoke_event, =>
                            @trigger new engine.events.Event "ran_away", {}, event
                @on "ran_away", (event) =>
                    @attack_count.should.equal 2
                    done()

        defender = new Creature()
        attacker = new Creature()
        attacker_2 = new Creature()

        defender = defender.trigger new engine.events.Event "run_away"

    it "will halt triggering of an event if a handler returns true", ->
        class Creature extends engine.things.Thing
            init: ->
                @hp = 10
            bind_events: ->
                @on "damage", (event) =>
                    @hp -= event.damage

        class ElectricProof extends Creature
            bind_events: ->
                @on "damage", (event) =>
                    return true if event.type is "electric"

        electric_damage = new engine.events.Event "damage", {damage:5, type:"electric"}
        creature_1 = new ElectricProof()
        creature_2 = new Creature()
        creature_1.trigger electric_damage
        creature_1.hp.should.equal 10
        creature_2.trigger electric_damage
        creature_2.hp.should.equal 5

    it "will halt triggering of an event if a callback returns true", (done) ->
        class Creature extends engine.things.Thing
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

        electric_damage = new engine.events.Event "damage", {damage:5, type:"electric"}
        creature_1 = new ElectricProof()
        creature_2 = new Creature()
        creature_1.trigger electric_damage, ->
            creature_1.hp.should.equal 10
            creature_2.trigger electric_damage, ->
                creature_2.hp.should.equal 5
                done()
    it "will remove the event if the last handler is removed", ->
        thing = new engine.things.Thing()
        handler = ->
        thing.on "custom_event", handler
        thing.off "custom_event", handler
        assert.ok thing._get_events()["custom_event"] is undefined
