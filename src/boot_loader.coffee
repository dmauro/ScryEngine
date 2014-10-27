engine.boot_game = (object) ->
    config = {}
    engine.utils.deep_extend config, engine.config, object.config
    application_constructor = engine.utils.constructor_from_string config.application_class
    application = new application_constructor config
    application.start()
