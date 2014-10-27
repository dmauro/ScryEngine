###
This is for classes that manage a particular
category of things. It will maintain an array
of the things (not just IDs) and needs to be
supplied with an array of  constructors to
watch for.

TODO: Maybe use this for sprites and brain managers?
###

class engine.RegistrySubcategory
    bind_to_registry: (registry) ->
        @things = []
        @registry = registry
        registry
        .on("registered_thing", @_add_thing_from_registry_event, @)
        .on("unregistered_thing", @_remove_thing_from_registry_event, @)
        .on("cached_thing", @_remove_thing_from_registry_event, @)
        .on("uncached_thing", @_add_thing_from_registry_event, @)

        # Get any things already in the registry
        for uuid, thing of registry.things
            @_add_thing thing

    _add_thing: (thing) ->
        for constructor in @subcategory_cnames
            constructor = engine.utils.constructor_from_string constructor
            if thing instanceof constructor
                @things.push thing
                if typeof @subcategory_thing_added is "function"
                    @subcategory_thing_added thing
                break

    _add_thing_from_registry_event: (event) ->
        @_add_thing event.thing

    _remove_thing_from_registry_event: (event) ->
        for constructor in @subcategory_cnames
            constructor = engine.utils.constructor_from_string constructor
            if event.thing instanceof constructor
                engine.utils.remove_val_from_array @things, event.thing
                if typeof @subcategory_thing_removed is "function"
                    @subcategory_thing_removed event.thing
                break
