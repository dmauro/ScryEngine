class engine.things.Sprite extends engine.things.NonAbstract
    @cname = "engine.things.Sprite"
    
    engine.things.define_defaults.call @,
        owner           : null
        width           : null # Int
        height          : null # Int
        size            : "medium"
        light_sources   : []
        visual_effects  : []
        sound_effects   : []
        smell_effects   : []
        touch_effects   : []

    engine.things.define_getter.call @, "width", ->
        return if @_width? then @_width else 1

    engine.things.define_getter.call @, "height", ->
        return if @_height? then @_height else 1

    for effect_type in ["visual", "sound", "smell", "touch"]
        ((effect_type) =>
            engine.things.define_getter.call @, "#{effect_type}_effects_level", ->
                level = 0
                for effect in @["#{effect_type}_effects"]
                    effect = @registry.get_thing effect
                    level = Math.max(level, effect.level) if effect
                return level
        )(effect_type)

    move_to: (x, y, z) ->
        prev_x = @x
        prev_y = @y
        prev_z = @z
        @x = x
        @y = y
        @z = z if z?
        z = @z unless z?
        @trigger new engine.events.SpriteMoved x, y, z, prev_x, prev_y, prev_z

    add_effect: (effect) ->
        stack = @["#{effect.type}_effects"]
        return unless stack
        stack.push effect.id
        @["#{effect.type}_effects"] = stack
        # TODO: Have everyone notice this effect
        # how are we gonna do that?

    remove_effect: (effect) ->
        stack = @["#{effect.type}_effects"]
        return unless stack
        engine.utils.remove_val_from_array stack, effect.id
        @["#{effect.type}_effects"] = stack

    add_light_source: (light_source) ->
        light_sources = @light_sources
        light_sources.push light_source.id
        @light_sources = light_sources

    remove_light_source: (light_source) ->
        light_sources = @light_sources
        engine.utils.remove_val_from_array light_sources, light_source.id
        @light_sources = light_sources
