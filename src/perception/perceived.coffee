###
This class represents things as
perceived by others.

We also need to know if we have los.
###

class engine.perception.Perceived
    constructor: (data) ->
        if data?
            @_restore data
        else
            @_init()

    _restore: (data) ->
        @_thing_id = data._thing_id
        @sense_levels = data.sense_levels

    _init: ->
        @_thing_id = null
        @sense_levels =
            sight       : 0
            hearing     : 0
            smelling    : 0
            touch       : 0

    get_property: (viewer, property) ->
        if typeof @get_property_handler is "function"
            return @get_property_handler viewer, @_thing_id, property, @sense_levels

