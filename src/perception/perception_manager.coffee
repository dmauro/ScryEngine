###
PerceptionManager
###

class engine.perception.PerceptionManager
    constructor: (data) ->
        if data?
            @_restore data
        else
            @_init()

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"
        ConstructorManager = @constructor_for_name "constructor_manager"
        SpriteManager = @constructor_for_name "sprite_manager"
        @constructor_manager = new ConstructorManager data.constructor_manager
        @sprite_manager = new SpriteManager data.sprite_manager
        filters = {}
        perception_layer_arrays = {}
        for id, filter of data.filters
            filters[id] = @constructor_manager.restore_object_from_data filter
        for id, layer_array of data.perception_layer_arrays
            layers = []
            for layer in layer_array
                layers.push @constructor_manager.restore_object_from_data layer
            perception_layer_arrays[id] = layers
        @filters = filters
        @perception_layer_arrays = perception_layer_arrays
        @brain_ids = data.brain_ids

    _init: ->
        ConstructorManager = @constructor_for_name "constructor_manager"
        SpriteManager = @constructor_for_name "sprite_manager"
        @constructor_manager = new ConstructorManager()
        @sprite_manager = new SpriteManager()
        @filters = {}
        @perception_layer_arrays = {}
        @brain_ids = []

    get_save_data: ->
        debugger
        filters = {}
        perception_layer_arrays = {}
        for id, filter of @filters
            filters[id] = @constructor_manager.get_save_data_from_object filter
        for id, layer_array of @perception_layer_arrays
            layers = []
            for layer in layer_array
                layers.push @constructor_manager.get_save_data_from_object layer
            perception_layer_arrays[id] = layers
        save_data =
            filters                 : filters
            brain_ids               : @brain_ids
            perception_layer_arrays : perception_layer_arrays
            constructor_manager     : @constructor_manager.get_save_data()
            sprite_manager          : @sprite_manager.get_save_data()
        return save_data

    constructor_for_name: (name) ->
        switch name
            when "constructor_manager"
                return engine.ConstructorManager
            when "player_filter"
                return engine.perception.PerceptionFilter
            when "non_player_filter"
                return engine.perception.PerceptionFilter
            when "sprite_perception_layer"
                return engine.perception.SpritePerceptionLayer
            when "sprite_manager"
                return engine.perception.SpriteManager

    bind_to_registry: (registry) ->
        for id, filter of @filters
            filter.bind_to_registry registry

        @sprite_manager.bind_to_registry registry

        registry
        .on("registered_brain", @_brain_added, @)
        .on("unregistered_brain", @_brain_removed, @)
        .on("cached_brain", @_brain_removed, @)
        .on("uncached_brain", @_brain_added, @)
        .on("registered_sprite", @_sprite_added, @)
        .on("unregistered_sprite", @_sprite_removed, @)
        .on("cached_sprite", @_sprite_removed, @)
        .on("uncached_sprite", @_sprite_added, @)

    _brain_added: (event) ->
        brain = event.thing
        brain_id = event.id
        filter = @filters[brain_id]
        unless filter?
            if brain instanceof engine.things.Player
                PerceptionFilter = @constructor_for_name "player_filter"
            else
                PerceptionFilter = @constructor_for_name "non_player_filter"
            filter = new PerceptionFilter()
            @filters[brain_id] = filter

        layer_array = @perception_layer_arrays[brain_id]
        unless layer_array?
            layer_array = []
            SpritePerceptionLayer = @constructor_for_name "sprite_perception_layer"
            for sprite in @sprite_manager.sprites
                layer = new SpritePerceptionLayer()
                layer.set_sprite sprite
                layer_array.push layer
            @perception_layer_arrays[brain_id] = layer_array

        brain.perception_handler = () =>
            # TODO: perception for this brain

    _brain_removed: (event) ->
        brain_id = event.id
        delete @filters[brain_id]
        delete @perception_layer_arrays[brain_id]

    _sprite_added: (event) ->
        sprite = event.thing
        SpritePerceptionLayer = @constructor_for_name "sprite_perception_layer"
        for brain_id in @brain_ids
            layer_array = @perception_layer_arrays[brain_id] ? []
            has_sprite = false
            for layer in layer_array
                if layer.get_sprite_id() is sprite.id
                    has_sprite = true
                    continue
            unless has_sprite
                layer = new SpritePerceptionLayer()
                layer.set_sprite sprite
                layer_array.push layer
            @perception_layer_arrays[brain_id] = layer_array

    _sprite_removed: (event) ->
        sprite = event.thing
        for brain_id in @brain_ids
            layer_array = @perception_layer_arrays[brain_id] ? []
            for layer in layer_array
                if layer.get_sprite_id is sprite.id
                    engine.utils.remove_val_from_array layer_array, layer
                    continue
            @perception_layer_arrays[brain_id] = layer_array
