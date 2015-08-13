###
PerceptionFilter
Each brain has an associated perception filter. This class
is responsible for reporting perceived properties back to
perception manager. It does so by either directly checking
those properties or using sprite perception layers to
help track the presence levels of sprites. These are stateless
objects that can be discarded and recreated on each launch.

This is a very basic filter that has been designed to be
subclassed.
###

class engine.perception.PerceptionFilter
    @cname = "engine.perception.PerceptionFilter"

    constructor: (data) ->
        if data?
            @_restore data
        else
            @_init()

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"

    _init: ->

    get_save_data: ->
        return {}

    filter: (viewer, thing, property, los_distance, path_distance, sense_levels) ->
        can_perceive_property = false
        for own sense, level of sense_levels
            can_perceive_property = @_can_perceive_thing_property viewer, thing, property, los_distance, path_distance, sense, level
            break if can_perceive_property

        if can_perceive_property
            return thing[property]
        else
            return undefined

    bind_to_registry: (registry) ->
        # TODO

    _can_perceive_thing_property: (viewer, thing, property, los_distance, path_distance, sense, level) ->
        can_perceive_function = @["_can_perceive_thing_property_with_#{sense}"]
        if typeof can_perceive_function is "function"
            return can_perceive_function thing, property, los_distance, path_distance, level
        else
            return false

    #######################
    # Methods to subclass #
    #######################

    _can_perceive_thing_property_with_sight: (viewer, thing, property, los_distance, path_distance, level) ->
        return level > 0

    _can_perceive_thing_property_with_hearing: (viewer, thing, property, los_distance, path_distance, level) ->
        return level > 0

    _can_perceive_thing_property_with_smelling: (viewer, thing, property, los_distance, path_distance, level) ->
        return level > 0

    _can_perceive_thing_property_with_touch: (viewer, thing, property, los_distance, path_distance, level) ->
        return level > 0
