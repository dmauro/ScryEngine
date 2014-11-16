###
This class is in charge of calculating
the lighting of every tile that is active
based on all light sources. The lighting
manager does not need to consider z coordinates
###

max_distance_for_brightest_light = 30

class engine.lighting.LightingManager extends engine.RegistrySubcategory
    constructor: ->
        @light_map = new engine.utils.MatrixArray()
        @subcategory_cnames = ["engine.things.LightSource"]
        super()

    ###########
    # Helpers #
    ###########

    constructor_for_name: (name) ->
        switch name
            when "light_tile"
                return engine.lighting.LightTile

    _get_light_sources_that_need_updates: ->
        need_updates = []
        for light_source in @things
            need_updates.push light_source if light_source.needs_update
        return need_updates

    _calculate_radius_for_intensity: (intensity) ->
        return Math.round intensity * max_distance_for_brightest_light

    _calculate_radius_for_light_source: (light_source) ->
        return @_calculate_radius_for_intensity light_source.intensity

    _get_brightness_for_distance_and_intensity: (distance, intensity) ->
        # Smooth out the radius
        distance += 0.25

        # Inverse-square law
        #intensity_at_distance = (intensity * max_distance_for_brightest_light)/(distance * distance)
        # Linear dropoff
        intensity_at_distance = intensity * ((max_distance_for_brightest_light - distance)/max_distance_for_brightest_light)

        # Stepoff
        steps = 5
        intensity_at_distance = Math.round(intensity_at_distance * steps)/steps

        return intensity_at_distance

    _get_affected_positions_for_origin_and_radius: (x, y, radius) ->
        within = []
        smooth_radius = radius + 0.25
        for py in [y - radius...y + radius + 1]
            for px in [x - radius...x + radius + 1]
                distance = engine.utils.get_distance_between_points [x, y], [px, py]
                if distance <= smooth_radius
                    within.push [px, py]
        return within

    _get_affected_tile_positions: (light_source) ->
        return @_get_affected_positions_for_origin_and_radius light_source.x, light_source.y, @_calculate_radius_for_light_source light_source

    #######################
    # Subcategory Methods #
    #######################

    subcategory_thing_added: (light_source) ->
        light_source
        .on("light_intensity_updated", @_light_intensity_updated, @)
        .on("light_color_updated", @_light_color_updated, @)
        .on("light_position_updated", @_light_position_updated, @)
        .on("light_applied", @_new_light_added_handler, @)
        
        @_new_light_added light_source


    subcategory_thing_removed: (light_source) ->
        light_source
        .off("light_intensity_updated", @_light_intensity_updated)
        .off("light_color_updated", @_light_color_updated)
        .off("light_position_updated", @_light_position_updated)
        .off("light_applied", @_new_light_added_handler)

        @_light_removed light_source

    ########################################
    # Light Source Update Reaction Methods #
    ########################################

    _new_light_added_handler: (event) ->
        @_new_light_added event.target

    _new_light_added: (light_source) ->
        return unless light_source.has_target

        tile_positions = @_get_affected_tile_positions light_source
        LightTile = @constructor_for_name "light_tile"
        for position in tile_positions
            x = position[0]
            y = position[1]
            light_tile = @light_map.get_value_at x, y
            unless light_tile
                light_tile = new LightTile()
                @light_map.set_value_at x, y, light_tile
            light_tile = light_tile or new LightTile()
            light_tile.light_sources.push light_source
            light_tile.needs_update = true

    _light_removed: (light_source) ->
        tile_positions = @_get_affected_tile_positions light_source
        for position in tile_positions
            x = position[0]
            y = position[1]
            light_tile = @light_map.get_value_at x, y
            if light_source in light_tile.light_sources
                engine.utils.remove_val_from_array light_tile.light_sources, light_source
                light_tile.needs_update = true

    _light_intensity_updated: (event) ->
        light_source = event.target
        intensity = event.value
        prev_intensity = event.prev_value
        max_intensity = Math.max intensity, prev_intensity
        max_radius = @_calculate_radius_for_intensity max_intensity
        max_affected = @_get_affected_positions_for_origin_and_radius light_source.x, light_source.y, max_radius
        min_intensity = Math.min intensity, prev_intensity
        min_radius = @_calculate_radius_for_intensity min_intensity
        min_affected = @_get_affected_positions_for_origin_and_radius light_source.x, light_source.y, min_radius
        is_new_max = intensity > prev_intensity

        # Larger radius
        LightTile = @constructor_for_name "light_tile"
        for position in max_affected
            light_tile = @light_map.get_value_at position[0], position[1]
            unless light_tile
                light_tile = new LightTile()
                @light_map.set_value_at position[0], position[1], light_tile
            light_tile.needs_update = true
            if is_new_max
                light_tile.light_sources.push light_source unless light_source in light_tile.light_sources
            else
                engine.utils.remove_val_from_array light_tile.light_sources, light_source

        # Smaller radius
        for position in min_affected
            light_tile = @light_map.get_value_at position[0], position[1]
            unless is_new_max
                light_tile.light_sources.push light_source
                light_tile.needs_update = true

    _light_color_updated: (event) ->
        light_source = event.target
        color = event.value
        for position in @_get_affected_positions_for_origin_and_radius light_source.x, light_source.y, @_calculate_radius_for_light_source light_source
            light_tile = @light_map.get_value_at position[0], position[1]
            light_tile.needs_update = true

    _light_position_updated: (event) ->
        light_source = event.target
        x = event.x
        y = event.y
        prev_x = event.prev_x
        prev_y = event.prev_y

        positions = @_get_affected_positions_for_origin_and_radius x, y, @_calculate_radius_for_light_source light_source
        prev_positions = @_get_affected_positions_for_origin_and_radius prev_x, prev_y, @_calculate_radius_for_light_source light_source

        LightTile = @constructor_for_name "light_tile"
        for position in prev_positions
            light_tile = @light_map.get_value_at position[0], position[1]
            light_tile.needs_update = true
            engine.utils.remove_val_from_array light_tile.light_sources, light_source

        for position in positions
            light_tile = @light_map.get_value_at position[0], position[1]
            unless light_tile
                light_tile = new LightTile()
                @light_map.set_value_at position[0], position[1], light_tile
            light_tile.needs_update = true
            light_tile.add_light_source light_source
        return


    ##################
    # Update Methods #
    ##################

    update: (bounds) ->
        ###
        This will get called externally on each action tick.
        It will iterate through the light map and update any
        light tiles that need updating.
        ###
        updated = []
        @light_map.for_each (light_tile, x, y, bounds) =>
            return unless light_tile.needs_update
            return if bounds and (x < bounds.left or x > bounds.right or y < bounds.top or y > bounds.bottom)
            return unless @get_tile_at_handler x, y
            light_tile.reset()
            for light_source in light_tile.light_sources
                if @has_los_between_points_handler x, y, light_source.x, light_source.y
                    distance_from_source = engine.utils.get_distance_between_points [x, y], [light_source.x, light_source.y]
                    brightness = @_get_brightness_for_distance_and_intensity distance_from_source, light_source.intensity
                    if brightness > 0
                        light_tile.add_light light_source.color, brightness
            updated.push {x: x, y: y, amount: light_tile.amount}
        return updated

    light_level_at_point: (x, y) ->
        light_level = 0
        light_tile = @light_map.get_value_at x, y
        light_level = light_tile.amount if light_tile
        return light_level

    light_color_at_point: (x, y) ->
        light_level = 0
        light_color = "000000"
        light_tile = @light_map.get_value_at x, y
        light_color = light_tile.color if light_tile
        light_level = light_tile.amount if light_tile
        return light_color
