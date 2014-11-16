class engine.Application
    constructor: ->
        Storage = @constructor_for_name "storage"
        @storage = new Storage()

    constructor_for_name: (name) ->
        switch name
            when "game"
                return engine.game
            when "char_gen"
                return engine.CharacterGenerator
            when "storage"
                return engine.Storage
            when "user"
                return engine.User
            when "menu_ui"
                return engine.ui.components.Menu()
            when "menu_data_source"
                return engine.ui.components.data_sources.MenuDataSource()

    start: ->
        User = @constructor_for_name "user"
        @user = new User()
        @show_main_menu()

    show_main_menu: ->
        Menu = @constructor_for_name "menu_ui"
        MenuDataSource = @constructor_for_name "menu_data_source"
        menu = new Menu()
        menu.data_source = new MenuDataSource [
                text    : "New Game"
                selection_callback  : =>
                    menu.dismiss =>
                        @start_new_game()
            ,
                text    : "Continue Game"
                selection_callback  : =>
                    menu.dismiss =>
                        data = @storage.get_item "quicksave"
                        data = data or @storage.get_item "fullsave"
                        @continue_game data
        ]
        menu.show()

    _save_game_data_locally: (data) ->
        serial_data = JSON.stringify data
        @storage.set_item "fullsave", serial_data
        @storage.remove_item "quicksave"

    _save_game_data_remotely: (data, callback) ->
        serial_data = JSON.stringify data
        # TODO: Send to server
        callback() if typeof callback is "function"

    create_game: (game_data_or_seed) ->
        Game = @constructor_for_name "game"
        @game = new Game game_data_or_seed

        @game.quicksave_handler = (data) =>
            serial_data = JSON.stringify data
            @storage.set_item "quicksave", serial_data

        @game.fullsave_handler = (data) =>
            @_save_game_data_locally data
            @_save_game_data_remotely data

        @game.exit_handler = =>
            @game.fullsave()
            @game = null
            @show_main_menu()

    start_new_game: ->
        CharGen = @constructor_for_name "char_gen"
        char_gen = new CharGen()
        char_gen.on_complete_callback = (character) =>
            @create_game()
            @game.set_protagonist character
            @game.start()
        char_gen.start()

    continue_game: (game) ->
        @create_game game
        @game.start()
