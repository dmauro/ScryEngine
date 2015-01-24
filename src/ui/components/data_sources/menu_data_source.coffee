class engine.ui.components.data_sources.MenuDataSource extends engine.ui.components.data_sources.DataSource
    @::__defineGetter__ "length", ->
        return @_menu_options.length

    constructor: (@_menu_options) ->

    get_option_text_at_index: (i) ->
        return @_menu_options[i].text

    get_option_selection_callback_at_index: (i) ->
        return @_menu_options[i].selection_callback
