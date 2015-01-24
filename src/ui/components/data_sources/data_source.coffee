###
DataSource
The base data source class provides data to a UI component.
All UI components should have an associated data source.
###
class engine.ui.components.data_sources.DataSource
    remove: ->
        @undbind_events()

    undbind_events: ->
