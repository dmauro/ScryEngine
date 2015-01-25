###
Action
The Action class represents any action that can be
undertaken by a single actor, which should be a Thing
subclass. Actions all take some time to complete (could
be 0) and they can have some data associated with them
to provide information for the do method to use.
Actions also have the registry and world available to
them in the do method.
###
class engine.actions.Action
    @cname = "engine.actions.Action"

    constructor: (@actor, @data, @world, @success_callback, @failure_callback) ->
        @registry = @actor.registry
        @time = 0;

    _get_time_to_complete: ->
        return @time

    do: ->
        if typeof @success_callback is "function"
            return @success_callback @_get_time_to_complete()
