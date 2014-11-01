class engine.Application
    constructor: (@config) ->

    start: ->
        @user = new engine.User()
        @show_main_menu()

    show_main_menu: ->
        menu = new engine.ui.components.Menu()
        menu.data_source = new engine.ui.components.data_sources.MenuDataSource [
                text    : "New Game"
                selection_callback  : =>
                    menu.dismiss =>
                        @start_new_game()
            ,
                text    : "Continue Game"
                selection_callback  : =>
                    menu.dismiss =>
                        data = localStorage?.getItem "quicksave"
                        data = data or localStorage?.getItem "fullsave"
                        @continue_game data
        ]
        menu.show()

    _save_game_data_locally: (data) ->
        serial_data = JSON.stringify data
        localStorage?.setItem "fullsave", serial_data
        localStorage?.removeItem "quicksave"

    _save_game_data_remotely: (data, callback) ->
        serial_data = JSON.stringify data
        # TODO: Send to server
        callback() if typeof callback is "function"

    _create_from_constructor_string: (string, args...) ->
        constructor = engine.utils.constructor_from_string string
        instance = new constructor args...
        return instance

    create_game: (game_data_or_seed) ->
        @game = @_create_from_constructor_string @config.game_class, @config, game_data_or_seed

        @game.quicksave_handler = (data) =>
            serial_data = JSON.stringify data
            localStorage?.setItem "quicksave", serial_data

        @game.fullsave_handler = (data) =>
            @_save_game_data_locally data
            @_save_game_data_remotely data

        @game.exit_handler = =>
            @game.fullsave()
            @game = null
            @show_main_menu()

    start_new_game: ->
        char_gen = @_create_from_constructor_string @config.chargen_class, engine.utils.constructor_from_string @config.base_player_thing_class
        char_gen.on_complete_callback = (character) =>
            @create_game()
            @game.set_protagonist character
            @game.start()
        char_gen.start()

    continue_game: (game) ->
        @create_game game
        @game.start()
