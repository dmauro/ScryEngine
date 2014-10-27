###
    TODO: Move game creation into Application, and just notify the user
###

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

    new_game: ->
        game = new engine.Game()
        @games.push game.id
        @current_game_id = game.id
        return game

    end_game: (id) ->
        index = @games.indexOf id
        @games.splice index, 1
        @current_game_id = null
        @bones.push id

    get_gamesave_from_remote: (id, callback) ->
        # Get the latest game
        return callback null

    restore_game_from_id: (id, callback) ->
        @get_gamesave_from_remote id, (save_data) ->
            return callback new engine.Game @, save_data

    restore_current_game: (callback) ->
        # This will try quicksave, otherwise local gamesave.
        # Falls back to remote, and will create a new game
        # if a saved game can't be found
        unless @current_game_id
            return callback new engine.Game @
        save_data = localStorage.getItem "quicksave" or localStorage.getItem "current_save"
        unless save_data? and JSON.parse(save_data).id is @current_game_id
            @get_gamesave_from_remote @current_game_id, (save_data) =>
                unless save_data?
                    return callback new engine.Game @
                return callback new engine.Game @, save_data
        return callback new engine.Game @, save_data
