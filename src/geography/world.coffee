###
The world class is responsible for
loading and unloading tiles as 
needed.
###

class engine.geography.World
    constructor: (data) ->
        if data
            @_restore data
        else
            @_init()
        @lighting_manager = new engine.LightingManager()
        @lighting_manager.get_tile_at_handler = (x, y) =>
            return @get_tile_at x, y
        @lighting_manager.has_los_between_points_handler = =>
            return @has_visual_los_between_points arguments...

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"
        @seed = data.seed
        @protagonist = data.protagonist
        @constructor_manager = new engine.ConstructorManager data.constructor_manager
        @geography_config = JSON.parse data.geography_config
        @loading_buffer = @geography_config.loading_buffer
        @zone_size = @geography_config.zone_size
        zone_manager_constructor = engine.utils.constructor_from_string @geography_config.zone_manager_class
        @zone_manager = new zone_manager_constructor data.zone_manager
        @strata = {}
        for level, stratum_data of data.strata
            @strata[level] = @_create_stratum stratum_data

    _init: ->
        @constructor_manager = new engine.ConstructorManager()
        @strata = {}

    bind_to_registry: (registry) ->
        @registry = registry
        @lighting_manager.bind_to_registry registry

    protagonist_ready: (protagonist) ->
        host = protagonist.get_host()
        @_track_protagonist_to host.x, host.y, host.z

    init: (protagonist, seed, geography_config) ->
        # This should only be called after we've bound it to the registry
        @protagonist = protagonist.id
        @geography_config = geography_config
        @loading_buffer = geography_config.loading_buffer
        @zone_size = geography_config.zone_size
        @seed = seed
        zone_manager_constructor = engine.utils.constructor_from_string geography_config.zone_manager_class
        @zone_manager = new zone_manager_constructor()
        @zone_manager.random = new engine.random.Alea null, [@seed]
        @zone_manager.init()

        # Set the spawn position for the protagonist
        spawn_pos = @_get_spawn_point()
        protagonist = @registry.get_thing @protagonist
        host = protagonist.get_host()
        host.move_to spawn_pos.x, spawn_pos.y, spawn_pos.z

    get_save_data: ->
        save_data =
            geography_config    : JSON.stringify @geography_config
            seed                : @seed
            protagonist         : @protagonist
            constructor_manager : @constructor_manager.get_save_data()
            zone_manager        : @zone_manager.get_save_data()
            strata              : {}
        for level, stratum of @strata
            save_data.strata[level] = stratum.get_save_data()
        return save_data

    start: ->
        @_track_protagonist()

    remove: ->
        @_stop_tracking_protagonist()

    ##################
    # Public Methods #
    ##################

    has_visual_los_between_points: (x1, y1, x2, y2) ->
        has_los = true
        dx = Math.abs x2 - x1
        dy = Math.abs y2 - y1
        sx = if x1 < x2 then 1 else -1
        sy = if y1 < y2 then 1 else -1
        err = dx - dy
        while not (x1 is x2 and y1 is y2)
            e2 = err << 1
            if e2 > -dy
                err -= dy
                x1 += sx
            if e2 < dx
                err += dx
                y1 += sy
            tile = @get_tile_at x1, y1
            if not tile or tile.is_opaque
                has_los = false
                break
        return has_los

    light_level_at_point: (x, y) ->
        return @lighting_manager.light_level_at_point x, y

    light_color_at_point: (x, y) ->
        return @lighting_manager.light_color_at_point x, y

    update_light_map: (bounds) ->
        return @lighting_manager.update bounds

    get_protagonist: ->
        return @registry.get_thing @protagonist

    get_tile_at: (x, y) ->
        # This will assume the stratum the protagonist is in
        return @tiles.get_value_at x, y

    get_seed_for_coordinate: (x, y, z) ->
        # Each seed should be deterministic based on location.
        # Based on Matthew Szudzik's pairing function
        # Read about it here: http://dmauro.com/???
        x = if x >= 0 then 2 * x else -2 * x - 1
        y = if y >= 0 then 2 * y else -2 * y - 1
        z = if z >= 0 then 2 * z else -2 * z - 1
        max = Math.max x, y, z
        hash = Math.pow(max, 3) + (2 * max * z) + z
        if max is z
            hash += Math.pow Math.max(x, y), 2
        if y >= x
            hash += x + y
        else
            hash += y
        return @seed + hash

    ###################
    # Creating Things #
    ###################

    _create_sprite_from_string_at: (string, x, y, z) ->
        constructor = engine.utils.constructor_from_string string
        sprite = new constructor()
        @registry.register_thing sprite
        sprite.move_to x, y, x
        return sprite

    ########################
    # Protagonist tracking #
    ########################

    _track_protagonist: ->
        protagonist = @get_protagonist()
        @_tracked_host = protagonist.get_host()
        protagonist.on "host_affected", @_host_changed_handler, @
        @_tracked_host.on "sprite_moved", @_sprite_moved_handler, @

    _stop_tracking_protagonist: ->
        @get_protagonist().off "host_affected", @_host_changed_handler
        @_tracked_host.off "sprite_moved", @_sprite_moved_handler

    _host_changed_handler: (event) ->
        @_tracked_host.off "sprite_moved", @_sprite_moved_handler
        @_tracked_host = protagonist.get_host()
        @_tracked_host.on "sprite_moved", @_sprite_moved_handler, @
        @_track_protagonist_to @_tracked_host.x, @_tracked_host.y, @_tracked_host.z

    _sprite_moved_handler: (event) ->
        @_track_protagonist_to event.x, event.y, event.z

    _track_protagonist_to: (x, y, z) ->
        # Anytime our protagonist moves, this will get called
        stratum = @_get_stratum_at_level z
        stratum.create_neighbor_zones_at x, y

        if @protagonist_stratum_level isnt z
            # Clear out tiles
            @protagonist_stratum_level = z
            @tiles = new engine.utils.MatrixArray()
        else
            # Unload any tiles outside of our buffer
            min_x = x - @loading_buffer
            max_x = x + @loading_buffer
            min_y = y - @loading_buffer
            max_y = y + @loading_buffer
            to_be_removed = []
            tiled_coordinates = new engine.utils.MatrixArray
            @tiles.for_each (tile_id, tile_x, tile_y) =>
                if (min_x <= tile_x <= max_x) and (min_y <= tile_y <= max_y)
                    tiled_coordinates.set_value_at tile_x, tile_y, true
                else
                    @tiles.remove_value_at tile_x, tile_y

        # Generate missing tiles within the buffer
        for py in [y - @loading_buffer..y + @loading_buffer]
            for px in [x - @loading_buffer..x + @loading_buffer]
                unless tiled_coordinates and tiled_coordinates.get_value_at(px, py)?
                    tile = stratum.create_tile_at px, py
                    @tiles.set_value_at px, py, tile
                    constructor_strings = stratum.get_and_remove_sprite_constructor_strings_at px, py
                    for constructor_string in constructor_strings
                        @_create_sprite_from_string_at constructor_string, px, py, z

        return

    ##########
    # Strata #
    ##########

    _create_stratum: (data) ->
        stratum = new engine.geography.Stratum data
        stratum.zone_size = @zone_size
        stratum.constructor_manager = @constructor_manager
        stratum.get_seed_for_coordinate_handler = (zone_x, zone_y) =>
            z_level = @_get_level_of_stratum stratum
            return @get_seed_for_coordinate zone_x, zone_y, z_level

        stratum.get_zone_info_handler = (zone_x, zone_y) =>
            z_level = @_get_level_of_stratum stratum
            return @zone_manager.get_zone_info_at zone_x, zone_y, z_level
        return stratum

    _get_level_of_stratum: (stratum) ->
        for z, strat of @strata
            return z if strat is stratum

    _get_stratum_at_level: (level) ->
        stratum = @strata[level]
        unless stratum
            stratum = @_create_stratum()
            @strata[level] = stratum
        return stratum

    _get_spawn_point: ->
        stratum_level = @_get_spawn_stratum_level()
        spawn_zone_position = @_get_spawn_zone_position()
        stratum = @_get_stratum_at_level stratum_level
        zone = stratum.get_zone_at_zone_position spawn_zone_position.x, spawn_zone_position.y
        spawn_point = zone.get_valid_spawn_point()
        spawn_point.z = stratum_level
        return spawn_point

    ####################
    # Subclass Methods #
    ####################

    _get_spawn_stratum_level: ->
        return 0

    _get_spawn_zone_position: ->
        return {x : 0, y : 0}
