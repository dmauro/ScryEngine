assert = require 'assert'
engine = require '../bin/engine'

describe "EventEmitter", ->

    EventEmitter = engine.events.EventEmitter
    Event = engine.events.Event
    event_name = "custom_name"
    emitter = null

    beforeEach ->
        emitter = new EventEmitter()
        
    it "will add a listener with an event name", ->
        event_handler = ->
        emitter.on event_name, event_handler
        assert.equal emitter._events[event_name][0]["listener"], event_handler, "Handler did not match."

    it "will add a listener without an event name", ->
        event_handler = (event) ->
        emitter.on null, event_handler
        assert.equal emitter._events["__all_events"][0]["listener"], event_handler, "Handler did not match."

    it "will trigger a listener for an event", ->
        debugger
        did_trigger = false
        emitter.on event_name, ->
            did_trigger = true
        emitter.trigger new Event event_name
        assert.ok did_trigger

    it "will trigger all listeners for an event in order added", ->
        count = 0
        emitter.on event_name, ->
            count += 1
            assert.equal count, 1
        emitter.on event_name, ->
            count += 1
            assert.equal count, 2
        emitter.trigger new Event event_name

    it "will not trigger an event after it has been removed", ->
        count = 0
        handler_one = ->
            count += 1
            assert.fail "Should not have called this handler"
        emitter.on event_name, handler_one
        emitter.on event_name, ->
        emitter.off event_name, handler_one
        emitter.trigger new Event event_name

    it "will wait for all events to complete before calling completion", (done) ->
        count = 0
        emitter.on event_name, (event, completion) ->
            count += 1
            assert.equal count, 1
            setTimeout ->
                completion()
            , 10
            return false
        emitter.on event_name, (event, completion) ->
            count += 1
            assert.equal count, 2
            setTimeout ->
                completion()
            , 10
        event = new Event event_name
        emitter.trigger event, ->
            done()

    it "will stop handling events if true is returned", ->
        count = 0
        emitter.on event_name, ->
            count += 1
            assert.equal count, 1
            return true
        emitter.on event_name, ->
            count += 1
        event = new Event event_name
        emitter.trigger event
        assert.equal count, 1

    it "can listen with a specified scope", ->
        scope = {}
        emitter.on event_name, ->
            assert.equal @, scope
        , scope
        emitter.trigger new Event event_name
