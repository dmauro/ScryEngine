###
Only used in tests currently
###

class engine.things.Condition extends engine.things.Abstract
    @cname = "engine.things.Condition"

    engine.things.define_defaults.call @,
        target              : null
        source              : null
        length              : 0
        counter             : 0
        canceling_events    : []

    apply: (target, source) ->
        # This will not get called when regenerating from save data
        @_target = target.id
        @_source = source.id if source?
        @_on()
        if @_length is 0
            @_off()
        @_bind_events()

    remove: ->
        @_unbind_events()
        @_off() if @_target?

    registry_available: (@registry) ->
        @_bind_events()

    _bind_events: ->
        if @_target?
            target = @registry.get_thing @_target
            if @_length > 0
                target.on "tick", @_tick_handler, @
            for event in @canceling_events
                target.on event, @remove, @

    _unbind_events: ->
        if @_target?
            target = @registry.get_thing @_target
            target.off "tick", @_tick_handler
            for event in @canceling_events
                target.off event, @remove

    _tick_handler: (event) ->
        @_tick event.time
        @counter += event.time
        if @counter >= @_length
            @remove()

    _on: ->
    _off: ->
    _tick: ->

    # TODO: We need some method for when we're tyring to add another of the same condition
