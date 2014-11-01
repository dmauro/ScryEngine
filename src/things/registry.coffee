#########################
# Thing Object Registry #
#########################

# TEMP HELPER
get_remaining_space = ->
    # Temp helper function
    if localStorage?
        return 1024 * 1024 * 5 - unescape(encodeURIComponent JSON.stringify localStorage).length
    else
        return 0

class engine.things.Registry extends engine.events.EventEmitter
    constructor: (data) ->
        @things = {}
        if data?
            @_restore data
        else
            @_init()
        for uuid, thing of @things
            continue if thing is null
            thing.activate_method_throughout_chain "registry_available", @

    _restore_thing_from_serial_data: (data) ->
        return @constructor_manager.restore_object_from_data data

    _prepare_thing_for_storing: (thing) ->
        return @constructor_manager.get_save_data_from_object thing

    _init: ->
        @id_count = 0
        @constructor_manager = new engine.ConstructorManager()

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"
        @id_count = data.id_count
        @constructor_manager = new engine.ConstructorManager data.constructor_manager
        for own id, thing_data of data.things
            if thing_data is null
                @things[id] = null
            else
                @things[id] = @_restore_thing_from_serial_data thing_data
        if data.cached_things?
            for own id, thing_data of data.cached_things
                localStorage?.setItem "thing_cache_#{id}", thing_data

    get_id: ->
        id = @id_count
        @id_count += 1
        return id

    register_thing: (thing) ->
        if thing.id?
            @_replace_thing thing
        else
            @_add_thing thing
        thing.registry = @
        thing.activate_method_throughout_chain "registry_available", @
        @trigger new engine.events.Base "registered_thing", {id:thing.id, thing:thing}
        if thing instanceof engine.things.Brain
            @trigger new engine.events.Base "registered_brain", {id:thing.id, thing:thing}
        return thing.id

    _add_thing: (thing) ->
        id = @get_id()
        thing.add_id id
        @things[id] = thing

    _replace_thing: (thing) ->
        @things[thing.id] = thing

    unregister_thing: (thing) ->
        delete @things[thing.id]
        @trigger new engine.events.Base "unregistered_thing", {id:thing.id, thing:thing}
        if thing instanceof engine.things.Brain
            @trigger new engine.events.Base "unregistered_brain", {id:thing.id, thing:thing}

    cache_thing: (id) ->
        thing = @things[id]
        thing.activate_method_throughout_chain "unbind_events"
        thing_serial_data = JSON.stringify @_prepare_thing_for_storing thing
        localStorage?.setItem "thing_cache_#{thing.id}", thing_serial_data
        @things[thing.id] = null
        @trigger new engine.events.Base "cached_thing", {id:id, thing:thing}
        if thing instanceof engine.things.Brain
            @trigger new engine.events.Base "cached_brain", {id:id, thing:thing}

    remove_cached_things_from_local_storage: ->
        for id, thing of @things
            if thing is null
                localStorage?.removeItem "thing_cache_#{id}"

    uncache_thing: (id) ->
        thing = @_restore_thing_from_serial_data JSON.parse localStorage?.getItem "thing_cache_#{id}"
        localStorage?.removeItem "thing_cache_#{id}"
        @things[id] = thing
        @trigger new engine.events.Base "uncached_thing", {id:id, thing:thing}
        if thing instanceof engine.things.Brain
            @trigger new engine.events.Base "uncached_brain", {id:id, thing:thing}
        return thing

    get_thing: (id) ->
        thing = @things[id]
        if thing is null
            thing = @uncache_thing id
        return thing

    get_things_with_position: (x, y) ->
        things = []
        for id, thing in @things
            if thing.x is x and thing.y is y
                things.push thing
        return thing

    _get_save_data: ->
        save_data =
            things              : {}
            cached_things       : {}
            id_count            : @id_count
            constructor_manager : @constructor_manager.get_save_data()
        return save_data

    _get_quicksave_data: ->
        # Leave cached stuff alone
        save_data = @_get_save_data()
        for own id, thing of @things
            if thing is null
                save_data.things[id] = null
            else
                save_data.things[id] = @_prepare_thing_for_storing thing
        return save_data

    _get_fullsave_data: ->
        # Return the save data
        save_data = @_get_save_data()
        for own id, thing of @things
            if thing is null
                save_data.cached_things[id] = localStorage?.getItem "thing_cache_#{id}"
            else
                save_data.things[id] = @_prepare_thing_for_storing thing
        return save_data

    get_save_data: (is_quicksave) ->
        if is_quicksave is true
            return @_get_quicksave_data()
        else
            return @_get_fullsave_data()
