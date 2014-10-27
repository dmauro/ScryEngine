###
This class handles reporting what we
know about a thing based on the perception
level that we are supplying.

This is a very basic filter designed to
be subclassed.
###

class engine.perception.PerceptionFilter
    filter: (viewer, thing, property, los_distance, path_distance, sense_levels) ->
        can_perceive_property = false
        for own sense, level of sense_levels
            can_perceive_property = @_can_perceive_thing_property viewer, thing, property, los_distance, path_distance, sense, level
            break if can_perceive_property

        if can_perceive_property
            return thing[property]
        else
            return undefined

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

