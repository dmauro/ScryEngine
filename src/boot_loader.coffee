class engine.BootLoader
    boot_game: (custom_config) ->
        config = {}
        engine.utils.deep_extend config, engine.config, custom_config
        Application = @constructor_for_name "application"
        application = new Application config
        application.start()

    constructor_for_name: (name) ->
        switch name
            when "application"
                return engine.Application
