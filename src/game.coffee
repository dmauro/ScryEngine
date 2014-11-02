class engine.Game
    constructor: (config, data_or_seed) ->
        if data_or_seed?
            if typeof data_or_seed is "string"
                @_restore config, data_or_seed
            else
                @_init config, data_or_seed
        else
            @_init config, +new Date()
            
        @perception_manager = new engine.perception.PerceptionManager()

        @timekeeper.bind_to_registry @registry
        @world.bind_to_registry @registry
        #@sprite_distance_manager.bind_to_registry @registry
        @perception_manager.bind_to_registry @registry

        # This will allow things to all display messages via the registry
        @registry.display_message_to_console = =>
            @display_message_to_console arguments...

        @timekeeper.turn_offered_handler = =>
            @map.draw_map() if @map

        @action_manager.stop_listening_for_actions = =>
            keypress?.stop_listening()

    _init: (config, seed) ->
        @config = config
        @id = engine.utils.generate_uuid Math.random
        @seed = seed
        @registry = @_create_registry()
        @timekeeper = engine.utils.create_from_constructor_string @config.timekeeper_class
        #@sprite_distance_manager = new engine.SpriteDistanceManager()
        @world = new engine.geography.World()
        @action_manager = new engine.actions.ActionManager @world
        @message_console = new engine.MessageConsole()

    _restore: (config, data) ->
        data = JSON.parse data if typeof data is "string"
        # We do this to ensure that once a game has started, we
        # don't override the config even if we update the game.
        # But we need to update the user settings as they change.
        updated_user_settings = config.user_settings
        @config = data.config
        @config.user_settings = updated_user_settings

        @id = data.id
        @seed = data.seed
        @registry = @_create_registry data.registry
        @timekeeper = engine.utils.create_from_constructor_string @config.timekeeper_class, data.timekeeper
        #@sprite_distance_manager = new engine.SpriteDistanceManager data.sprite_distance_manager
        @world = new engine.geography.World data.world
        @action_manager = new engine.actions.ActionManager @world
        @message_console = new engine.MessageConsole data.message_console

        @_protagonist_ready @registry.get_thing @world.protagonist

    _create_registry: (data) ->
        cache = engine.utils.create_from_constructor_string @config.registry_cache_class
        return engine.utils.create_from_constructor_string @config.thing_registry_class, cache, data

    set_protagonist: (creature) ->
        @registry.register_thing creature
        player_character = engine.utils.create_from_constructor_string @config.player_character_class
        @registry.register_thing player_character
        creature.give_sentience player_character
        @world.init player_character, @seed, @config.geography
        @_protagonist_ready player_character

    _protagonist_ready: (player_character) ->
        player_character.listen_for_actions_handler = (success_callback, failure_callback) =>
            @player_action_success_callback = success_callback
            @player_action_failure_callback = failure_callback
            keypress?.listen()
        player_character.offerred_turn_handler = =>
            # Every time the player is offered a turn we will auto-save
            @quicksave()
        @_bind_player_actions player_character
        @world.protagonist_ready player_character

    _get_save_data: (is_quicksave=false) ->
        save_data =
            id                      : @id
            seed                    : @seed
            config                  : @config
            timekeeper              : @timekeeper.get_save_data is_quicksave
            #sprite_distance_manager : @sprite_distance_manager.get_save_data()
            message_console         : @message_console.get_save_data is_quicksave
            world                   : @world.get_save_data is_quicksave
            # Registry needs to come after world because the world might delete tiles
            registry                : @registry.get_save_data is_quicksave
        return save_data

    _get_quicksave_data: ->
        ###
        Quicksave leaves stuff in storage that is cached.
        This is the method that will be called after every action
        by the player.
        ###
        return @_get_save_data true

    _get_fullsave_data: ->
        ###
        This gets all the data to send back to the server for
        storage for long term. This also grabs cached things so
        it will be a little slower.
        ###
        return @_get_save_data false

    quicksave: ->
        # Local only save that relies on cached things for speed
        data = @_get_quicksave_data()
        @quicksave_handler data if typeof @quicksave_handler is "function"

    fullsave: ->
        # Full data that will persist even with cache wiped
        data = @_get_fullsave_data()
        @fullsave_handler data if typeof @fullsave_handler is "function"
        @registry.remove_cached_things_from_local_storage()

    display_message_to_console: (message, args...) ->
        @message_console.show_message message, args...

    show_game_ui: ->
        # TODO: Render UI components
        map = new engine.ui.components.TileMap
        map.data_source = new engine.ui.components.data_sources.TileMapDataSource @world, @config.ui.tile_map
        map.show()
        @map = map

    start: ->
        # Called when the game is starting or resuming
        @world.start()
        @show_game_ui()
        @timekeeper.start()

    end: ->
        # Called when the game has ended
        @timekeeper.end()

    exit: ->
        # Called when pausing or abandoning the game
        @exit_handler() if typeof @exit_handler is "function"
        @world.remove()
        @timekeeper.remove()
        @map.dismiss()

    _bind_player_actions: (player) ->
        # Example bindings for now
        # This will get pulled in from config?
        bindings = [
                keys    : "w"
                action  : engine.actions.Walk
                data    :
                    x : 0
                    y : -1
            ,
                keys    : "a"
                action  : engine.actions.Walk
                data    :
                    x : -1
                    y : 0
            ,
                keys    : "s"
                action  : engine.actions.Walk
                data    :
                    x : 0
                    y : 1
            ,
                keys    : "d"
                action  : engine.actions.Walk
                data    :
                    x : 1
                    y : 0
        ]

        for binding in bindings
            ((binding)=>
                keypress?.combo binding.keys, =>
                    @action_manager.do_action player, binding.action, binding.data or {}, (time) =>
                        @player_action_success_callback time
                    , (error_message) =>
                        @player_action_failure_callback error_message
                , true
            )(binding)

        keypress?.combo "escape", =>
            @exit()
