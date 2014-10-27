###
This maintains an unordered list of all
brains in the game. It does not need to
get saved as it will just recreate the
list from the registry.
###

class engine.BrainManager
    constructor: ->
        @brains = []

    bind_to_registry: (registry) ->
        @registry = registry
        registry
        .on("registered_brain", @_add_brain_from_registry_event, @)
        .on("unregistered_brain", @_remove_brain_from_registry_event, @)
        .on("cached_brain", @_remove_brain_from_registry_event, @)
        .on("uncached_brain", @_add_brain_from_registry_event, @)

        for own id, thing of registry.things
            if thing instanceof engine.things.Brain
                @brains.push thing

    _add_brain_from_registry_event: (event) ->
        @brains.push event.thing

    _remove_brain_from_registry_event: (event) ->
        engine.utils.remove_val_from_array @brains, event.thing
