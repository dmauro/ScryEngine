###
SpriteManager
This tracks the distances between sprites
to aid in perception because we want to
use pathfinding distances for hearing and
smelling, rather than LOS distances.

This should be owned by the perception manager.
###

class engine.perception.SpriteManager
    constructor: (data) ->
        if data
            @_restore data
        else
            @_init()

    _restore: (data) ->
        # Sprites don't get restored from ID until the registry is binded
        # but this array normally holds references to the sprites themselves.
        @sprites = data.sprites
        @positions = data.positions
        @distances = new engine.utils.RelationshipDictionary data.distances

    _init: ->
        @sprites = []
        @positions = {}
        @distances = new engine.utils.RelationshipDictionary()

    bind_to_registry: (registry) ->
        @registry = registry
        registry
        .on("registered_sprite", @_add_sprite_from_registry_event, @)
        .on("unregistered_sprite", @_remove_sprite_from_registry_event, @)
        .on("cached_sprite", @_remove_sprite_from_registry_event, @)
        .on("uncached_sprite", @_add_sprite_from_registry_event, @)

        sprites = []
        for id in @sprites
            thing = @registry.get_thing id
            @_bind_movement_for_sprite thing
            sprites.push thing
        @sprites = sprites

    _add_sprite_from_registry_event: (event) ->
        @sprites.push event.thing
        @_sprite_moved event.thing, event.thing.x, event.thing.y
        @_bind_movement_for_sprite event.thing
        if typeof @sprite_added_handler is "function"
            @sprite_added_handler(event.thing)

    _remove_sprite_from_registry_event: (event) ->
        @_unbind_movement_for_sprite event.thing
        engine.utils.remove_val_from_array @sprites, event.thing
        if typeof @sprite_removed_handler is "function"
            @sprite_removed_handler(event.thing)

    _bind_movement_for_sprite: (sprite) ->
        sprite.on "sprite_moved", @_sprite_movement_handler, @

    _unbind_movement_for_sprite: (sprite) ->
        sprite.off "sprite_moved", @_sprite_movement_handler, @

    _sprite_movement_handler: (event) ->
        @_sprite_moved event.target, event.x, event.y

    _sprite_moved: (sprite, x, y) ->
        @positions[sprite.id] = [x, y]
        # Calculate distances to other sprites
        id = sprite.id
        for other_sprite in @sprites
            continue if sprite is other_sprite
            position = @positions[other_sprite.id]
            distance = 0 # DO PATHFINDING HERE
            # Note: what is the cap distance? We shouldn't find a
            # path if it is too long.
            previous_distance = @distances.get_value_for_keys id, other_sprite.id
            if distance != previous_distance
                # We should call a distance updated function here so the
                # perception manager can be told
                @distances.set_value_for_keys id, other_sprite.id, distance

    get_save_data: ->
        save_data =
            sprites     : []
            positions   : @positions
            distances   : @distances.get_save_data()
        for sprite in @sprites
            save_data.sprites.push sprite.id
        return save_data

    ##################
    # Public queries #
    ##################

    get_path_distance_between: (id1, id2) ->
        return @distances.get_value_for_keys id1, id2

    get_los_distance_between: (id1, id2) ->
        point1 = @positions[id1]
        point2 = @positions[id2]
        return engine.utils.get_distance_between_points point1, point2
