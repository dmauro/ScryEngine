class engine.ui.components.data_sources.QueryDataSource extends engine.ui.components.data_sources.DataSource
    @::__defineGetter__ "length", ->
        return @_queries.length

    @::__defineGetter__ "query_title", ->
        return @_title

    @::__defineGetter__ "submit_label", ->
        return @_submit_label

    constructor: (@_title, @_submit_label, @_queries) ->

    get_query_label_at_index: (i) ->
        return @_queries[i].label

    get_query_name_at_index: (i) ->
        return @_queries[i].name
