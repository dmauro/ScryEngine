###
Event
The Event class propagates information by being dispatched
by an EventEmitter subclass. The event is dispatched and
anyone listening for the event on that object will be notified.
###
class engine.events.Event
    constructor: (@name, data={}, @parent_event) ->
        for own key, value of data
            throw new Error "Trying to override a reserved event property: #{key}" if @key?
            @[key] = value

    get_root_event: ->
        parent = @
        while parent.parent_event?
            parent = parent.parent_event
        return parent

    get_callstack: ->
        root = @get_root_event
        return root.callstack or root.callstack = []
