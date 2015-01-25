###
Zone
The zone is a collection of tiles that is grouped together both for
performance and to allow for easier "theming" of areas of the world.
All zones in a world are the same number of tiles squared, and that
size is determined by the world.

The zone can only contain tiles that are listed in its tile_constructors
property. They are stored as indices to aid in world persistence.

This is designed to be subclassed by overriding the _init_tiles method.
###
class engine.geography.zones.Zone
    @cname = "engine.geography.zones.Zone"
    
    tile_constructors: [
        "engine.geography.tiles.Tile"
    ]

    sprite_constructors: []

    constructor: (data) ->
        if data?
            @_restore data

    _restore: (data) ->
        MatrixArray = @constructor_for_name "matrix_array"
        @size = data.size
        @random = new engine.random.Alea data.random
        @tile_constructor_indices = data.tile_constructor_indices
        @sprite_constructor_indices = new MatrixArray data.sprite_constructor_indices
        console.log "Sprites after restore #{JSON.stringify @sprite_constructor_indices}"

    init: (size, random_seed, entrances, pathways) ->
        @size = size
        @random = new engine.random.Alea null, [random_seed]
        @tile_constructor_indices = @_init_tiles entrances, pathways
        @sprite_constructor_indices = @_init_sprites()

    constructor_for_name: (name) ->
        switch name
            when "matrix_array"
                return engine.utils.MatrixArray

    get_tile_constructor_at: (local_x, local_y) ->
        tile_index = local_x + local_y * @size
        constructor_index = @tile_constructor_indices[tile_index]
        constructor_string = @tile_constructors[constructor_index]
        return engine.utils.constructor_from_string constructor_string

    get_sprite_constructor_strings_at: (local_x, local_y) ->
        indices = @sprite_constructor_indices.get_value_at local_x, local_y
        array = []
        if indices
            for constructor_index in indices
                constructor_string = @sprite_constructors[constructor_index]
                array.push constructor_string if constructor_string
        return array

    remove_sprite_constructors_at: (local_x, local_y) ->
        @sprite_constructor_indices.remove_value_at local_x, local_y

    get_valid_spawn_point: ->
        return {x : 0, y : 0}

    get_save_data: ->
        save_data =
            size                        : @size
            random                      : @random.get_save_data()
            tile_constructor_indices    : @tile_constructor_indices
            sprite_constructor_indices  : @sprite_constructor_indices.get_save_data()
        return save_data

    #Tile Generation
    
    _init_tiles: (entrances, pathways) ->
        # If we are passed entrances or pathways,
        # they should be respected.
        tiles = []
        for y in [0...@size]
            for x in [0...@size]
                tiles.push 0
        return tiles

    # Thing Placement

    _init_sprites: ->
        # Returns a Matrix array of arrays of tile constructor indices
        MatrixArray = @constructor_for_name "matrix_array"
        return new MatrixArray()
