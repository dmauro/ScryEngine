class engine.CharacterGenerator
    constructor: (base_class) ->
        @character = new base_class()

    start: ->
        charname_query = new engine.ui.components.Query()
        charname_query.data_source = new engine.ui.components.data_sources.QueryDataSource "What's your character's name?", null, [
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

