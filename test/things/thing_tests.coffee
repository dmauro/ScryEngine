should = require 'should'
assert = require 'assert'
engine = require '../../bin/engine'

describe "Thing", ->
    it "will wipe a property that is set to the same as a default", ->
        class Humanoid extends engine.things.Thing
            engine.things.define_defaults.call @,
                maxhp : 0

        humanoid = new Humanoid()
        default_value = humanoid._maxhp
        humanoid.maxhp = 5
        assert.ok humanoid.hasOwnProperty "_maxhp"
        humanoid.maxhp = default_value
        assert.ok !humanoid.hasOwnProperty "_maxhp"

    it "can create from serial data", ->
        humanoid = new engine.things.Thing()
        humanoid.size = "large"
        data = humanoid.get_save_data()
        new_guy = new engine.things.Thing data
        assert.ok JSON.stringify(humanoid.get_save_data()) == JSON.stringify(new_guy.get_save_data())

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
            class Thing extends engine.things.Thing
                init: ->
                    incr()
            class NewerThing extends Thing
                init: ->
                    incr()
            instance = new NewerThing()

    describe "Property chaining", ->
        it "will trigger property chains of ancestors and self", (done) ->
            class First extends engine.things.Thing
                @property_chains:
                    foo : ["bar"]
            class Second extends First
                @property_chains:
                    baz : ["qux"]
            thing = new Second()
            count = 0
            incr = ->
                count += 1
                if count >= 2
                    done()
                return
            thing.on "property_affected", (event) ->
                if event.property in ["bar", "qux"]
                    incr()
                return
            thing.trigger new engine.events.ThingPropertyAffected "foo"
            thing.trigger new engine.events.ThingPropertyAffected "baz"

        it "will do event chaining first in first out", (done) ->
            class First extends engine.things.Thing
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
            class First extends engine.things.Thing
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
            class First extends engine.things.Thing
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
                        @trigger new engine.events.Event "another_event", {}, event
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
            thing.trigger new engine.events.Event "custom_event", {}
            thing.trigger new engine.events.ThingPropertyAffected "baz"
            
        it "will chain through to all affected properties when one is changed", (done) ->
            class Thing extends engine.things.Thing
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
