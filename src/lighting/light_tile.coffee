class engine.lighting.LightTile
    constructor: ->
        @light_sources = []
        @reset()

    reset: ->
        @amount = 0
        @color = "000000"
        @needs_update = false

    add_light_source: (light_source) ->
        @light_sources.push light_source unless light_source in @light_sources

    add_light: (color, brightness) ->
        @amount += brightness
        color = engine.utils.multiply_hex_number color, brightness
        @color = engine.utils.add_hex_colors @color, color
