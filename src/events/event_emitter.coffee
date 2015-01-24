###
EventEmitter
An event emitter is a class which can dispatch and listen
for events.
###
class engine.events.EventEmitter
    _get_events: ->
        return @_events or @_events = {}

    _get_listeners: (event_name) ->
        events = @_get_events()
        return events[event_name] or events[event_name] = []

    on: (event_name, listener, scope) ->
        # Things should only ever call this from their
        # bind_events function because we don't store the listeners
        # through a save and restore.
        if typeof listener isnt "function"
            return
            # TODO: Handle this error!
        listeners = @_get_listeners event_name
        is_already_listening = false
        for value in listeners
            if value.listener is listener
                is_already_listening = true
                break
        unless is_already_listening
            listeners.push(
                listener    : listener
                scope       : scope or @
            )
        return @

    off: (event_name, listener) ->
        if listener
            listeners = @_get_listeners event_name
            for value in listeners
                if value.listener is listener
                    engine.utils.remove_val_from_array listeners, value
                    @remove_event event_name unless listeners.length
                    break
        else if event_name
            @remove_event event_name
        else
            @_events = {}
        return @

    remove_event: (event_name) ->
        if event_name
            @_get_events()[event_name] = undefined
        else
            @_events = undefined
        return @

    trigger: (event, callback=->) ->
        event.target = @
        listeners = @_get_listeners event.name
        call_loop = (index) =>
            return callback() unless listeners[index]?
            listener = listeners[index].listener
            scope = listeners[index].scope
            call_result = listener.call scope, event, (should_stop_handling) ->
                if should_stop_handling is true
                    return callback()
                call_loop index + 1
            if call_result is true
                return callback()
            unless call_result is false
                call_loop index + 1
        call_loop 0
