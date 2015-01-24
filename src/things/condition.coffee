###
Condition
This class represents a change that should happen to another
thing for some duration. The class can take any actions needed
on the target Thing when it is turned on, turned off, and at
every one of the thing's ticks.

An example of the relationship between the Condition and the
Effect classes: if something were to become on fire, it could
have a flaming condition, that condition might add effects to
the target sprite that make it lit up and another when it is
done to make the target smelly.

TODO: Conditions need to communicate with other conditions
affecting that target. For instance, a soaked condition could
BOTH prevent and cancel a flaming condition, but those conditions
might also have relative strengths that might want to compete.
Additionally adding a flaming condition when one already exists
may just do nothing or add to the duration of the existing one.
We might need to build support for this into the base Thing, but
how can we also simplify this so every condition doesn't need to 
special case its interaction with every other. Can we make a
condition matrix?
###
class engine.things.Condition extends engine.things.Abstract
    @cname = "engine.things.Condition"

    engine.things.define_defaults.call @,
        target              : null
        source              : null
        duration            : 0
        counter             : 0
        # TODO: canceling_events could be replaced with something
        # more robust...
        canceling_events    : []

    apply: (target, source) ->
        # This will not get called when regenerating from save data
        @_target = target.id
        @_source = source.id if source?
        @_on()
        if @_duration is 0
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
            if @_duration > 0
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
        if @counter >= @_duration
            @remove()

    _on: ->
    _off: ->
    _tick: ->
