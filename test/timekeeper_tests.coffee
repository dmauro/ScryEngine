should = require 'should'
assert = require 'assert'
engine = require '../bin/engine'

describe "Timekeeping", ->
    timekeeper = null
    registry = null
    brain = null
    beforeEach ->
        timekeeper = new engine.TimeKeeper()
        registry = new engine.things.Registry()
        timekeeper.bind_to_registry registry

    it "adds new entries for brains", ->
        brain = new engine.things.Brain()
        registry.register_thing brain
        timekeeper.things.length.should.equal 1

    it "uses the timekeepers time as new thing entry time", ->
        brain = new engine.things.Brain()
        timekeeper.time = 5
        registry.register_thing brain
        timekeeper.things[0].time.should.equal timekeeper.time

    it "can offer turns to things in order", (done) ->
        turn_count = 0

        finish = ->
            brain_1.turns_taken.should.equal 2
            brain_2.turns_taken.should.equal 3
            timekeeper.time.should.equal 6
            done()

        class Brain extends engine.things.Brain
            take_turn: (action_manager, callback) ->
                if turn_count >= 5
                    finish()
                else
                    turn_count += 1
                    setTimeout(=>
                        @turns_taken += 1
                        return callback @time_for_action
                    , 1)

        brain_1 = new Brain()
        brain_2 = new Brain()
        brain_1.time_for_action = 3
        brain_2.time_for_action = 2
        brain_1.turns_taken = brain_2.turns_taken = 0
        registry.register_thing brain_1
        registry.register_thing brain_2
        timekeeper.start()

    it "in the event of a tie, the thing that went less recently goes first", (done) ->
        class Brain extends engine.things.Brain
            take_turn: (action_manager, callback) ->
                setTimeout(=>
                    @turns_taken += 1
                    return callback @time_for_action
                , 10)
        brain_1 = new Brain()
        brain_2 = new Brain()
        brain_1.time_for_action = 1
        brain_2.time_for_action = 2
        brain_1.turns_taken = brain_2.turns_taken = 0
        registry.register_thing brain_1
        registry.register_thing brain_2
        timekeeper.start()
        setTimeout(->
            brain_1.turns_taken.should.equal 1
            timekeeper.time.should.equal 0
        , 19)
        setTimeout(->
            brain_2.turns_taken.should.equal 1
            timekeeper.time.should.equal 1
        , 29)
        setTimeout(->
            brain_1.turns_taken.should.equal 2
            timekeeper.time.should.equal 2
        , 39)
        setTimeout(->
            # Now they are both at 2 seconds, brain_2 should get to go
            brain_2.turns_taken.should.equal 2
            timekeeper.time.should.equal 2
            done()
        , 49)
