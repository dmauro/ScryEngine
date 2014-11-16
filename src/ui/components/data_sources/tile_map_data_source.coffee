class engine.ui.components.data_sources.TileMapDataSource extends engine.ui.components.data_sources.Base
    @::__defineGetter__ "center_x", ->
        return Math.floor @x + @host_width/2

    @::__defineGetter__ "center_y", ->
        return Math.floor @y + @host_height/2

    @::__defineGetter__ "sprites", ->
        return []
        #return @protagonist.aware_of

    @::__defineSetter__ "data_source", (data_source) ->
        @data_source = data_source

    @::config =
        tile_width  : 20
        tile_height : 20
        view_width  : 24
        view_height : 16

    constructor: (@world) ->
        @view_width = @config.view_width
        @view_height = @config.view_height
        @tile_width = @config.tile_width
        @tile_height = @config.tile_height
        @protagonist = @world.get_protagonist()
        @host = @protagonist.get_host()
        @protagonist.on "host_affected", @_host_changed_handler, @
        @host.on "sprite_moved", @_update_protagonist_location, @
        @_update_protagonist_location()

    _host_changed_handler: (event) ->
        @host.off "sprite_moved", @_update_protagonist_location
        @host = @protagonist.get_host()
        @host.on "sprite_moved", @_update_protagonist_location, @
        @_update_protagonist_location()

    _update_protagonist_location: ->
        @x = @host.x
        @y = @host.y
        @z = @host.z
        @host_width = @host.width
        @host_height = @host.height

    get_tile_at: (x, y) ->
        return @world.get_tile_at x, y

    visibility_at_point: (x, y, light_level) ->
        visibility = 0
        host_x = @host.x
        host_y = @host.y

        if @protagonist.senses.touch is 10
            visibility += 1
        else if @protagonist.senses.sight is 10 and @world.has_visual_los_between_points x, y, host_x, host_y
            light_level = light_level ? @world.light_level_at_point x, y
            visibility += light_level

        if @protagonist.senses.touch > 0
            if Math.abs(x - host_x) <= 1 and Math.abs(y - host_y) <= 1
                visibility += 0.5

        visibility = Math.min 1, visibility

        return visibility

    light_color_at_point: (x, y) ->
        return @world.light_color_at_point x, y

    update_light_map: (bounds) ->
        @world.update_light_map bounds

    unbind_events: ->
        @host.off "sprite_moved", @_update_protagonist_location
