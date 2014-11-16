class engine.CharacterGenerator
    constructor: () ->
        PlayerThing = @constructor_for_name "player_thing"
        @character = new PlayerThing()

    constructor_for_name: (name) ->
        switch name
            when "player_thing"
                return engine.things.Sentient
            when "query_ui"
                return engine.ui.components.Query
            when "query_ui_data_source"
                return engine.ui.components.data_sources.QueryDataSource

    start: ->
        Query = @constructor_for_name "query_ui"
        QueryDataSource = @constructor_for_name "query_ui_data_source"
        charname_query = new Query()
        charname_query.data_source = new QueryDataSource "What's your character's name?", null, [
            {
                name    : "character_name"
            }
        ]
        charname_query.on_submit_callback = (response) =>
            @character.fullname = response["character_name"]
            charname_query.dismiss =>
                @finish()
        charname_query.show()

    finish: ->
        @on_complete_callback(@character) if @on_complete_callback?

