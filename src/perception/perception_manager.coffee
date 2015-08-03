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
        BrainManager = @constructor_for_name "brain_manager"
        @constructor_manager = new ConstructorManager data.constructor_manager
        @sprite_manager = new SpriteManager data.sprite_manager
        @brain_manager = new BrainManager()
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

    _init: ->
        ConstructorManager = @constructor_for_name "constructor_manager"
        SpriteManager = @constructor_for_name "sprite_manager"
        BrainManager = @constructor_for_name "brain_manager"
        @constructor_manager = new ConstructorManager()
        @sprite_manager = new SpriteManager()
        @brain_manager = new BrainManager()
        @filters = {}
        @perception_layer_arrays = {}

    get_save_data: ->
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
            perception_layer_arrays : perception_layer_arrays
            sprite_manager          : @sprite_manager.get_save_data()
            constructor_manager     : @constructor_manager.get_save_data()
        return save_data

    constructor_for_name: (name) ->
        switch name
            when "constructor_manager"
                return engine.ConstructorManager
            when "sprite_manager"
                return engine.perception.SpriteManager
            when "brain_manager"
                return engine.perception.BrainManager
            when "player_filter"
                return engine.perception.PerceptionFilter
            when "non_player_filter"
                return engine.perception.PerceptionFilter
            when "sprite_perception_layer"
                return engine.perception.SpritePerceptionLayer

    # TODO: Call these from timekeeper

    bind_to_registry: (registry) ->
        for id, filter of @filters
            filter.bind_to_registry registry
        @sprite_manager.bind_to_registry registry
        @brain_manager.bind_to_registry registry

    _setup_handlers: ->
        @sprite_manager.sprite_added_handler = (sprite) =>
            @sprite_added sprite
        @sprite_manager.sprite_removed_handler = (sprite) =>
            @sprite_removed sprite
        @brain_manager.brain_added_handler = (brain) =>
            @brain_added brain
        @brain_manager.brain_removed_handler = (brain) =>
            @brain_removed brain.id

    brain_added: (brain) ->
        filter = @filters[brain.id]
        unless filter?
            if brain instanceof engine.things.Player
                PerceptionFilter = @constructor_for_name "player_filter"
            else if brain instanceof engine.things.NonPlayer
                PerceptionFilter = @constructor_for_name "non_player_filter"
            filter = new PerceptionFilter()
            @filters[brain.id] = filter

        layer_array = @perception_layer_arrays[brain.id]
        unless layer_array?
            layer_array = []
            SpritePerceptionLayer = @constructor_for_name "sprite_perception_layer"
            for sprite in @sprite_manager.sprites
                layer = new SpritePerceptionLayer()
                layer.set_sprite sprite
                layer_array.push layer
            @perception_layer_arrays[brain.id] = layer_array

        brain.perception_handler = () =>
            # TODO: perception for this brain

    brain_removed: (brain_id) ->
        delete @filters[brain_id]
        delete @perception_layer_arrays[brain_id]

    sprite_added: (sprite) ->
        SpritePerceptionLayer = @constructor_for_name "sprite_perception_layer"
        for brain in @brains
            layer_array = @perception_layer_arrays[brain.id] ? []
            has_sprite = false
            for layer in layer_array
                if layer.get_sprite_id() is sprite.id
                    has_sprite = true
                    continue
            unless has_sprite
                layer = new SpritePerceptionLayer()
                layer.set_sprite sprite
                layer_array.push layer
            @perception_layer_arrays[brain.id] = layer_array

    sprite_removed: (sprite) ->
        for brain in @brains
            layer_array = @perception_layer_arrays[brain.id] ? []
            for layer in layer_array
                if layer.get_sprite_id is sprite.id
                    engine.utils.remove_val_from_array layer_array, layer
                    continue
            @perception_layer_arrays[brain.id] = layer_array
