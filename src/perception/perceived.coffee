###
Perceived
This is a layer between a brain and a sprite that it is
perceiving. This layer ensures the brain doesn't know
more than it should about the perceived sprite.

This object will also listen for effects for us to
catch spikes in the sensory levels while the brain
wasn't specifically watching.
###

class engine.perception.Perceived
    constructor: (data) ->
        if data?
            @_restore data
        else
            @_init()

    _restore: (data) ->
        @_thing_id = data._thing_id
        @presence_levels = data.presence_levels

    _init: ->
        @_sprite_id = null
        @presence_levels =
            sight       : 0
            hearing     : 0
            smelling    : 0
            touch       : 0

    constructor_for_name: (name) ->
        switch name
            when "effect_applied"
                return engine.events.EffectApplied
        return super? arguments...

    bind_to_registry: (registry) ->
        @registry = registry
        sprite = @get_sprite()
        EffectApplied = @constructor_for_name "effect_applied"
        sprite.on EffectApplied::event_name, (event) ->
            # TODO: Check if this spikes the presence levels

    get_save_data: ->
        save_data =
            _sprite_id      : @_sprite_id
            presence_levels : @presence_levels

    set_sprite: (sprite) ->
        @_sprite_id = sprite.id

    get_sprite: ->
        return @registry.get_thing @_sprite_id

    get_property: (viewer, property) ->
        if typeof @get_property_handler is "function"
            return @get_property_handler viewer, @get_sprite(), property, @sense_levels

