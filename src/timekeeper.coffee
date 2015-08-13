###
TimeKeeper
This class is in charge of making sure all things in the
world are offered turns according to how long they spent
doing their last action.
###
class engine.TimeKeeper
    constructor: (data) ->
        if data?
            @_restore data
        else
            @_init()

    _init: ->
        @things = []
        @time = 0
        PerceptionManager = @constructor_for_name "perception_manager"
        @perception_manager = new PerceptionManager()

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"
        @things = []
        for value in data.things
            @things.push value
        @time = data.time
        PerceptionManager = @constructor_for_name "perception_manager"
        @perception_manager = new PerceptionManager(data.perception_manager)
        
    get_save_data: ->
        save_data =
            things              : []
            time                : @time
            perception_manager  : @perception_manager.get_save_data()
        for value in @things
            # Just save the id of the things
            save_data.things.push(
                thing   : value.thing.id
                time    : value.time
            )
        return save_data

    constructor_for_name: (name) ->
        switch name
            when "perception_manager"
                return engine.perception.PerceptionManager

    bind_to_registry: (registry) ->
        @registry = registry
        @perception_manager.bind_to_registry registry
        
        registry.on("registered_brain", (event) =>
            @_add_thing event.id, event.thing
        ).on("unregistered_brain", (event) =>
            @_remove_thing event.id
        ).on("cached_brain", (event) =>
            @_remove_thing event.id
        ).on("uncached_brain", (event) =>
            @_add_thing event.id, event.thing
        )
        # Restore things from ids after save
        for value in @things
            thing = registry.get_thing value.thing
            value.thing = thing
            throw new Error "Timekeeper had thing not in registry?!" unless thing?

    _add_thing: (id, thing, time) ->
        unless time?
            time = @time
        @things.push(
            thing   : thing
            time    : time
        )

    _remove_thing: (id) ->
        for i in [0...@things.length]
            if @things[i].thing.id is id
                @things.splice i, 1
                return

    _offer_next_turn: ->
        next = @_get_index_of_thing_with_least_time()
        @time = @things[next].time
        @_offer_turn next

    _get_index_of_thing_with_least_time: ->
        min = {index:null, time:Infinity}
        for i in [0...@things.length]
            time = @things[i].time
            if time < min.time
                min = {index:i, time:time}
        return min.index

    _offer_turn: (index) ->
        if typeof @turn_offered_handler is "function"
            @turn_offered_handler()
        return if @is_ended?
        # Push this to the back of the queue
        value = @things.splice(index, 1)[0]
        @things.push value
        index = @things.length - 1
        thing = value.thing
        thing.take_turn @action_manager, (time) =>
            return if @is_ended?
            @things[index].time += time
            @_offer_next_turn()

    start: ->
        @_offer_next_turn()
        
    end: ->
        @is_ended = true

    remove: ->
        @registry.off()
