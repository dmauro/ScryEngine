class engine.Game
    constructor: (data_or_seed) ->
        is_restoring = false
        if data_or_seed?
            if typeof data_or_seed is "string"
                is_restoring = true
                @_restore data_or_seed
            else
                @_init data_or_seed
        else
            @_init +new Date()
            
        ActionManager = @constructor_for_name "action_manager"
        @action_manager = new ActionManager @world
        PerceptionManager = @constructor_for_name "perception_manager"
        @perception_manager = new PerceptionManager @action_manager

        @timekeeper.bind_to_registry @registry
        @world.bind_to_registry @registry
        #@sprite_distance_manager.bind_to_registry @registry
        @perception_manager.bind_to_registry @registry

        # This will allow things to all display messages via the registry
        @registry.display_message_to_console = =>
            @display_message_to_console arguments...

        @timekeeper.turn_offered_handler = =>
            @map.draw_map() if @map

        if is_restoring
            @_protagonist_ready @registry.get_thing @world.protagonist

    constructor_for_name: (name) ->
        switch name
            when "perception_manager"
                return engine.perception.PerceptionManager
            when "timekeeper"
                return engine.TimeKeeper
            when "world"
                return engine.geography.World
            when "action_manager"
                return engine.actions.ActionManager
            when "message_console"
                return engine.MessageConsole
            when "registry"
                return engine.things.Registry
            when "keyboard_manager"
                return engine.input.KeyboardManager
            when "map"
                return engine.ui.components.TileMap
            when "map_data_source"
                return engine.ui.components.data_sources.TileMapDataSource
            when "player_character"
                return engine.things.Player
            when "player_playback"
                return engine.things.PlayerPlayback
            when "game_history"
                return engine.GameHistory

    _init: (seed) ->
        @id = engine.utils.generate_uuid Math.random
        @seed = seed # currently unused
        TimeKeeper = @constructor_for_name "timekeeper"
        World = @constructor_for_name "world"
        MessageConsole = @constructor_for_name "message_console"
        GameHistory = @constructor_for_name "game_history"
        @registry = @_create_registry()
        @timekeeper = new TimeKeeper()
        @world = new World()
        @message_console = new MessageConsole()
        @game_history = new GameHistory()

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"

        @id = data.id
        @seed = data.seed
        TimeKeeper = @constructor_for_name "timekeeper"
        World = @constructor_for_name "world"
        MessageConsole = @constructor_for_name "message_console"
        GameHistory = @constructor_for_name "game_history"
        @registry = @_create_registry data.registry
        @timekeeper = new TimeKeeper data.timekeeper
        @world = new World data.world
        @message_console = new MessageConsole data.message_console
        @protagonist_start_info = data.protagonist_start_info
        @game_history = new GameHistory data.game_history

    _create_registry: (data) ->
        Registry = @constructor_for_name "registry"
        return new Registry data

    _define_player_action_mappings: (player) ->
        bindings = [
                name    : "walk_north"
                action  : engine.actions.Walk
                data    :
                    x : 0
                    y : -1
            ,
                name    : "walk_west"
                action  : engine.actions.Walk
                data    :
                    x : -1
                    y : 0
            ,
                name    : "walk_south"
                action  : engine.actions.Walk
                data    :
                    x : 0
                    y : 1
            ,
                name    : "walk_east"
                action  : engine.actions.Walk
                data    :
                    x : 1
                    y : 0
        ]

        # TODO: Get key inputs from config instead of hard-coding
        key_mappings =
            "walk_north"    : "w"
            "walk_west"     : "a"
            "walk_south"    : "s"
            "walk_east"     : "d"

        @player_action_mappings = {}
        for binding in bindings
            ((binding)=>
                keys = key_mappings[binding.name]
                @player_action_mappings[keys] = =>
                    @_player_input_off()
                    ((action_class, data) =>
                        @action_manager.do_action player, action_class, data, (time) =>
                            @_record_player_action action_class, data
                            @player_action_success_callback time
                        , (error_message) =>
                            @_player_input_on()
                            @player_action_failure_callback error_message
                    )(binding.action, binding.data or {})
            )(binding)

    _setup_keyboard_manager: ->
        KeyboardManager = @constructor_for_name "keyboard_manager"
        @keyboard_manager = new KeyboardManager()
        # TODO: Send actual bindings
        @player_keyboard_input = @keyboard_manager.bind_input_layer @player_action_mappings, false
        #@global_ui_keyboard_input = @keyboard_manager.bind_input_layer undefined, false

    _player_input_on: ->
        @player_keyboard_input.on()

    _player_input_off: ->
        @player_keyboard_input.off()

    _record_player_action: (action_class, data) ->
        @game_history.add_action action_class, data

    _protagonist_ready: (player_character) ->
        player_character.listen_for_actions_handler = (success_callback, failure_callback) =>
            @player_action_success_callback = success_callback
            @player_action_failure_callback = failure_callback
            @_player_input_on()

        player_character.offerred_turn_handler = =>
            # Every time the player is offered a turn we will auto-save
            @quicksave()

        @_define_player_action_mappings player_character
        @_setup_keyboard_manager()
        @world.protagonist_ready player_character

    _get_save_data: (is_quicksave=false) ->
        save_data =
            id                      : @id
            seed                    : @seed
            timekeeper              : @timekeeper.get_save_data is_quicksave
            #sprite_distance_manager : @sprite_distance_manager.get_save_data()
            message_console         : @message_console.get_save_data is_quicksave
            world                   : @world.get_save_data is_quicksave
            # Registry needs to come after world because the world might delete tiles
            registry                : @registry.get_save_data is_quicksave
            protagonist_start_info  : @protagonist_start_info
            game_history            : @game_history.get_save_data()
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

    _save_starting_protagonist: (creature) ->
        ###
        We need to save the host we started with so that we can
        playback later. This is a one-of-a-kind so we don't need
        to get fancy with storing the cname
        ###
        @protagonist_start_info =
            cname   : creature.constructor.cname
            data    : creature.get_save_data()

    set_protagonist: (creature) ->
        @_save_starting_protagonist creature
        @registry.register_thing creature
        PlayerCharacter = @constructor_for_name "player_character"
        player_character = new PlayerCharacter()
        @registry.register_thing player_character
        creature.give_sentience player_character
        @world.init player_character, @seed
        @_protagonist_ready player_character

    playback: (creature, game_history) ->
        # Prevent saving
        @quicksave_handler = ->
            return
        @fullsave_handler = ->
            return
        GameHistory = @constructor_for_name "game_history"
        game_history = new GameHistory game_history
        @registry.register_thing creature
        PlayerPlayback = @constructor_for_name "player_playback"
        player_playback = new PlayerPlayback()
        player_playback.game_history = game_history
        @registry.register_thing player_playback
        creature.give_sentience player_playback
        @world.init player_playback, @seed
        @world.protagonist_ready player_playback

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
        Map = @constructor_for_name "map"
        MapDataSource = @constructor_for_name "map_data_source"
        map = new Map()
        map.data_source = new MapDataSource @world
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
