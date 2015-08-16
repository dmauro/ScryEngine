should = require 'should'
assert = require 'assert'
engine = require '../../bin/engine'

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
        class TestAction extends engine.actions.Action
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
        class TestAction extends engine.actions.Action
            _get_time_to_complete: ->
                return 3
        action_manager.do_action brain, TestAction, {}, (time) ->
            time.should.equal 3
