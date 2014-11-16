engine.config =
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
