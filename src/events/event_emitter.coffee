###
EventEmitter
An event emitter is a class which can dispatch and listen
for events.

NOTE: The event name "__all_events" is reserved and should
never be used.
###
class engine.events.EventEmitter
    _all_events_name: "__all_events"

    _get_events: ->
        return @_events or @_events = {}

    _get_listeners: (event_name) ->
        events = @_get_events()
        return events[event_name] or events[event_name] = []

    _remove_event: (event_name) ->
        if event_name
            @_get_events()[event_name] = undefined
        else
            @_events = undefined
        return @

    on: (event_name, listener, scope) ->
        ###
        This should generally only be called from the bind_events
        method of a thing. The listeners do not get stored with a
        save and restore, so they must be set up each time.

        If the event_name is null or undefined, we will listen to
        all events on this object. The only way to remove that
        handler is to pass the same handler into the off method
        with a null or undefined event_name or by calling the off
        method with no params to remove all of the listeners.

        The optional scope parameter allows us to specify the scope
        with which the listener is called. The default scope is this
        object.
        ###
        event_name = @_all_events_name unless event_name?
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
        ###
        This method can be invoked in a few different ways.

        @off() will simply remove all listeners for this object.
        @off(event_name) will remove all listeners for the
            specified event name.
        @off(event_name, listener) will remove the listener
            associated with the event_name. The event_name can be
            null or undefined if it was added as such.
        ###
        if listener
            event_name = @_all_events_name unless event_name?
            listeners = @_get_listeners event_name
            for value in listeners
                if value.listener is listener
                    engine.utils.remove_val_from_array listeners, value
                    @_remove_event event_name unless listeners.length
                    break
        else if event_name
            @_remove_event event_name
        else
            @_events = {}
        return @

    trigger: (event, callback=->) ->
        ###
        This will trigger the specified event and cause it to be
        sent to all relevant listeners. The optional callback
        will only be called when all listeners have had their chance
        to respond to the notification.

        Listners are called with the event as the first parameter
        and an async completion handler for the second parameter.
        To use the async completion handler to signal that you are done
        with the event, pass back false in your listener immediately.

        You can return true in your listener or by calling the completion
        handler with true in the should_stop_handling param to stop
        all further handling of this event. No other listeners queued up
        to receive the event will receive it and the completion block will
        be called immediately.
        ###
        event.target = @
        listeners = @_get_listeners event.name
        if event.name?
            listeners.concat @_get_listeners @_all_events_name

        # Prevent callback multi-calling
        finish = ->
            completion_callback = callback
            callback = ->
            completion_callback()

        call_loop = (index) =>
            return finish() unless listeners[index]?
            listener = listeners[index].listener
            scope = listeners[index].scope
            call_result = listener.call scope, event, (should_stop_handling) ->
                return if call_result is true
                if should_stop_handling is true
                    return finish()
                call_loop index + 1
            if call_result is true
                return finish()
            unless call_result is false
                call_loop index + 1
        call_loop 0
