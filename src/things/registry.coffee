#########################
# Thing Object Registry #
#########################

class engine.things.Registry extends engine.events.EventEmitter
    constructor: (data, @cache) ->
        @things = {}
        # Cache can be passed in to help with testing
        unless @cache?
            Cache = @constructor_for_name "cache"
            @cache = new Cache()
        if data?
            @_restore data
        else
            @_init()
        for uuid, thing of @things
            continue if thing is null
            thing.activate_method_throughout_chain "registry_available", @

    constructor_for_name: (name) ->
        switch name
            when "cache"
                return engine.Storage
            when "constructor_manager"
                return engine.ConstructorManager

    _restore_thing_from_serial_data: (data) ->
        return @constructor_manager.restore_object_from_data data

    _prepare_thing_for_storing: (thing) ->
        return @constructor_manager.get_save_data_from_object thing

    _init: ->
        @id_count = 0
        ConstructorManager = @constructor_for_name "constructor_manager"
        @constructor_manager = new ConstructorManager()

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"
        @id_count = data.id_count
        ConstructorManager = @constructor_for_name "constructor_manager"
        @constructor_manager = new ConstructorManager data.constructor_manager
        for own id, thing_data of data.things
            if thing_data is null
                @things[id] = null
            else
                @things[id] = @_restore_thing_from_serial_data thing_data
        if data.cached_things?
            for own id, thing_data of data.cached_things
                @cache.set_item "thing_cache_#{id}", thing_data

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
        @trigger new engine.events.Event "registered_thing", {id:thing.id, thing:thing}
        if thing instanceof engine.things.Brain
            @trigger new engine.events.Event "registered_brain", {id:thing.id, thing:thing}
        return thing.id

    _add_thing: (thing) ->
        id = @get_id()
        thing.add_id id
        @things[id] = thing

    _replace_thing: (thing) ->
        @things[thing.id] = thing

    unregister_thing: (thing) ->
        # I should get rid of this
        delete @things[thing.id]
        @trigger new engine.events.Event "unregistered_thing", {id:thing.id, thing:thing}
        if thing instanceof engine.things.Brain
            @trigger new engine.events.Event "unregistered_brain", {id:thing.id, thing:thing}

    cache_thing: (id) ->
        thing = @things[id]
        thing.activate_method_throughout_chain "unbind_events"
        thing_serial_data = JSON.stringify @_prepare_thing_for_storing thing
        @cache.set_item "thing_cache_#{thing.id}", thing_serial_data
        @things[thing.id] = null
        @trigger new engine.events.Event "cached_thing", {id:id, thing:thing}
        if thing instanceof engine.things.Brain
            @trigger new engine.events.Event "cached_brain", {id:id, thing:thing}

    remove_cached_things_from_local_storage: ->
        for id, thing of @things
            if thing is null
                @cache.remove_item "thing_cache_#{id}"

    uncache_thing: (id) ->
        data = @cache.get_item "thing_cache_#{id}"
        if data?
            thing = @_restore_thing_from_serial_data JSON.parse data
            @cache.remove_item "thing_cache_#{id}"
            @things[id] = thing
            @trigger new engine.events.Event "uncached_thing", {id:id, thing:thing}
            if thing instanceof engine.things.Brain
                @trigger new engine.events.Event "uncached_brain", {id:id, thing:thing}
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

    _get_save_data: (things, cached_things) ->
        save_data =
            things              : things
            cached_things       : cached_things
            id_count            : @id_count
            constructor_manager : @constructor_manager.get_save_data()
        return save_data

    _get_quicksave_data: ->
        # Leave cached stuff alone
        things = {}
        for own id, thing of @things
            if thing is null
                things[id] = null
            else
                things[id] = @_prepare_thing_for_storing thing
        return @_get_save_data things, {}

    _get_fullsave_data: ->
        # Return the save data
        things = {}
        cached_things = {}
        for own id, thing of @things
            if thing is null
                cached_things[id] = @cache.get_item "thing_cache_#{id}"
            else
                things[id] = @_prepare_thing_for_storing thing
        return @_get_save_data things, cached_things

    get_save_data: (is_quicksave) ->
        if is_quicksave is true
            return @_get_quicksave_data()
        else
            return @_get_fullsave_data()
