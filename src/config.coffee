engine.config =
    application_class           : "engine.Application"
    game_class                  : "engine.Game"
    chargen_class               : "engine.CharacterGenerator"
    base_player_thing_class     : "engine.things.Sentient"
    player_character_class      : "engine.things.Player"
    thing_registry_class        : "engine.things.Registry"
    timekeeper_class            : "engine.TimeKeeper"
    storage_class               : "engine.Storage"
    registry_cache_class        : "engine.Storage"
        
    user_settings: {}

    geography:
        zone_manager_class  : "engine.geography.ZoneManager"
        zone_size           : 64 # Should be divisible by 2
        loading_buffer      : 64 # Should be: max(view_width, view_height) <= buffer <= zone_size
    ui:
        tile_map:
            tile_width  : 20
            tile_height : 20
            view_width  : 24
            view_height : 16
