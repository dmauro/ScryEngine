class engine.things.LightSource extends engine.things.Abstract
    @cname = "engine.things.LightSource"

    engine.things.define_defaults.call @,
        intensity       : 0
        color           : "ffffff"

    engine.things.define_getter.call @, "has_target", ->
        return @_target?

    engine.things.define_getter.call @, "x", ->
        unless @_x?
            target = @registry.get_thing @_target
            @_x = target?.x
        return @_x

    engine.things.define_getter.call @, "y", ->
        unless @_y?
            target = @registry.get_thing @_target
            @_y = target?.y
        return @_y

    engine.things.define_setter.call @, "intensity", (value) ->
        prev_value = @_intensity
        @_intensity = value
        @trigger new engine.events.Event "light_intensity_updated", {value:value, prev_value:prev_value}

    engine.things.define_setter.call @, "color", (value) ->
        @_color = value
        @trigger new engine.events.Event "light_color_updated", {value:value}

    registry_available: (registry) ->
        # If we already have a target, we need to bind to it
        target_id = @_target
        if target_id?
            target = registry.get_thing target_id
            target.on "sprite_moved", @_sprite_moved, @

    apply: (target) ->
        # Cache the target's position
        @_x = target.x
        @_y = target.y

        @_target = target.id
        target.add_light_source @
        target.on "sprite_moved", @_sprite_moved, @

        @trigger new engine.events.Event "light_applied"

    remove: (target) ->
        target = target or @registry.get_thing @_target
        target.remove_light_source @
        @_target = undefined
        target.off "sprite_moved", @_sprite_moved, @

    _sprite_moved: (event) ->
        # Cache the host position
        @_x = event.x
        @_y = event.y

        @trigger new engine.events.Event "light_position_updated", {x:event.x, y:event.y, prev_x:event.prev_x, prev_y:event.prev_y}
