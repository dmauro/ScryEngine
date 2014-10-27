###
This tracks the distances between sprites
to aid in perception because we want to
use pathfinding distances for hearing and
smelling, rather than LOS distances.
###

class engine.SpriteDistanceManager
    constructor: (data) ->
        if data
            @_restore data
        else
            @_init()

    _restore: (data) ->
        # We can actually store the things in here rather than their
        # IDs because we can be sure that they are not cached away.
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
        .on("registered_thing", @_add_thing_from_registry_event, @)
        .on("unregistered_thing", @_remove_thing_from_registry_event, @)
        .on("cached_thing", @_remove_thing_from_registry_event, @)
        .on("uncached_thing", @_add_thing_from_registry_event, @)

        for id in @sprites
            thing = @registry.get_thing id
            @_bind_movement_for_sprite thing
            @sprites.push thing

    _add_thing_from_registry_event: (event) ->
        if event.thing instanceof engine.things.Sprite
            @sprites.push event.thing
            @_sprite_moved event.thing, event.thing.x, event.thing.y
            @_bind_movement_for_sprite event.thing

    _remove_thing_from_registry_event: (event) ->
        if event.thing instanceof engine.things.Sprite
            @_unbind_movement_for_sprite event.thing
            engine.utils.remove_val_from_array @sprites, event.thing

    _bind_movement_for_sprite: (sprite) ->
        sprite.on "sprite_moved", @_sprite_movement_handler, @

    _unbind_movement_for_sprite: (sprite) ->
        sprite.off "sprite_moved", @_sprite_movement_handler, @

    _sprite_movement_handler: (event) ->
        @_sprite_moved event.target, event.x, event.y

    _sprite_moved: (sprite, x, y) ->
        @positions[sprite.id] =
            x : x
            y : y
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
