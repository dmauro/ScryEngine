class engine.actions.Base
    constructor: (@actor, @data, @world, @success_callback, @failure_callback) ->
        @registry = @actor.registry
        @time = 0;

    _get_time_to_complete: ->
        return @time

    do: ->
        if typeof @success_callback is "function"
            return @success_callback @_get_time_to_complete()
