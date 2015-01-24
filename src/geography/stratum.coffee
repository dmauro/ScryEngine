###
Stratum
A stratum represents a single z-layer in the world.
This should only be subclassed if added functionality
is needed.
###

###
A note about coordinates:
There are three types of coordinates used here:

Global coordinates
Zone coordinates
Local coordinates

Global coordinates are tile coordinates that range from
-n to +n and differentiate tiles on a global scale.
These will be labeled simply as x and y.

Zone coordinates range from -n to +n and differentiate
zones on a global scale. These will be labeled as zone_x
and zone_y.

Local coordinates are tile coordinates that range from
0 to zone_size - 1 and differentiate tiles in the same zone.
These will be labeled as local_x and local_y.
###

class engine.geography.Stratum
    constructor: (data) ->
        if data
            @_restore data
        else
            @_init()

    _restore: (data) ->
        @zones = new engine.utils.MatrixArray data.zones
        @zones.for_each (value, x, y) =>
            @zones.set_value_at x, y, @constructor_manager.restore_object_from_data value

    _init: ->
        @zones = new engine.utils.MatrixArray()

    get_save_data: ->
        save_data = {}
        save_data.zones = @zones.get_save_data (value) =>
            return @constructor_manager.get_save_data_from_object value

    ##########
    # Public #
    ##########

    create_tile_at: (x, y) ->
        constructor = @_get_tile_constructor_at x, y
        return new constructor()

    get_and_remove_sprite_constructor_strings_at: (x, y) ->
        zone = @_get_zone_at x, y
        local_coordinate = @_get_local_coordinate_from_global_coordinate x, y
        strings = zone.get_sprite_constructor_strings_at local_coordinate.x, local_coordinate.y
        if strings.length
            zone.remove_sprite_constructors_at local_coordinate.x, local_coordinate.y
        return strings

    get_zone_at_zone_position: (zone_x, zone_y) ->
        zone = @zones.get_value_at zone_x, zone_y
        unless zone
            zone = @_create_zone_at zone_x, zone_y
        return zone

    create_neighbor_zones_at: (x, y) ->
        # Generate neighboring zones that don't exist from global coords
        zone_coords = @_get_zone_coordinate_from_global_coordinate x, y
        for zy in [zone_coords.y - 1..zone_coords.y + 1]
            for zx in [zone_coords.x - 1..zone_coords.x + 1]
                # Don't create them if they exist
                @get_zone_at_zone_position zx, zy

    ###########
    # Helpers #
    ###########

    _create_zone_at: (zone_x, zone_y) ->
        if typeof @get_zone_info_handler is "function"
            zone_info = @get_zone_info_handler zone_x, zone_y
            zone = new zone_info.constructor()
            if typeof @get_seed_for_coordinate_handler is "function"
                seed = @get_seed_for_coordinate_handler zone_x, zone_y
            zone.init @zone_size, seed, zone_info.entrances, zone_info.pathways
            @zones.set_value_at zone_x, zone_y, zone
            return zone

    _get_tile_constructor_at: (x, y) ->
        zone = @_get_zone_at x, y
        local_coordinate = @_get_local_coordinate_from_global_coordinate x, y
        return zone.get_tile_constructor_at local_coordinate.x, local_coordinate.y

    _get_zone_at: (x, y) ->
        # Return which zone falls under this global coordinate
        zone_coordinate = @_get_zone_coordinate_from_global_coordinate x, y
        return @zones.get_value_at zone_coordinate.x, zone_coordinate.y

    _get_zone_coordinate_from_global_coordinate: (x, y) ->
        return {
            x : Math.floor x/@zone_size
            y : Math.floor y/@zone_size
        }

    _get_local_coordinate_from_global_coordinate: (x, y) ->
        x = x % @zone_size
        y = y % @zone_size
        if x < 0
            x += @zone_size
        if y < 0
            y += @zone_size
        return { x : x, y : y }
