class engine.User
    constructor: (data) ->
        if data?
            @_restore data
        else
            @_init()

    _init: ->
        @current_game_id = null
        @preferences = {}
        @games = [] #IDs of current games
        @bones = [] #IDs of past games

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"
        for own property, value of data
            @[property] = value

    get_save_data: ->
        return @

    add_game_id: (id) ->
        @games.push id
        @current_game_id = id

    remove_game_id: (id) ->
        index = @games.indexOf id
        @games.splice index, 1
        @current_game_id = null
        @bones.push id
