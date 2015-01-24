###
These helpers are used for all classes to define any
setters or getters. All properties should have getters,
and anything intended to be public needs a setter.
###
engine.things.define_getter = (property, getter) ->
    @::__defineGetter__ property, ->
        value = getter.call @
        value = @check_for_property_modifiers property, value
        return value

engine.things.define_setter = (property, setter) ->
    @::__defineSetter__ property, (v) ->
        setter.call @, v
        @trigger new engine.events.ThingPropertyChange property

engine.things.define_defaults = (defaults) ->
    for own property, value of defaults
        @::["_" + property] = value
        do (property) =>
            engine.things.define_setter.call @, property, (v) ->
                @['_' + property] = v
            engine.things.define_getter.call @, property, ->
                value = @["_" + property]
                if value and typeof value is "object"
                    unless @hasOwnProperty "_#{property}"
                        ###
                        If the value is an object and we don't have our
                        own value, return a shallow copy to ensure we
                        don't mess with the prototype's default value.

                        Object properties should never be modified directly.
                        There should always be helper methods.
                        ###
                        if value instanceof Array or Object.prototype.toString.call(value) is '[object Array]'
                            value = value.slice()
                            # TODO: Override this Array so that it
                            # complains loudly if it gets modified
                        else
                            new_object = {}
                            for own k, v of value
                                new_object[k] = v
                            value = new_object
                            # TODO: Override this object so that it
                            # complains loudly if it gets modified.
                return value

###
Thing
This is our base thing class. A thing is anything that can be thought
of as having some sort of presence in the game world, excluding the tiles
themselves, but including things like effects and light. All thing
classes need to ultimately descend from this class.
###
class engine.things.Thing extends engine.events.EventEmitter
    ###
    All classes must have a cname property that is a string
    representing how to find the class from the root object.
    ###
    @cname = "engine.things.Thing"

    constructor: (data) ->
        # Allow us to recreate from data
        for own property, value of data
            @[property] = value

        # This property will be excluded
        @_property_modifier_handlers = {}

        # Any special init conditions for each class that inherits
        unless data
            @activate_method_throughout_chain "init"

        # Bind any events this thing has
        # This should only be used to bind events to onself
        @activate_method_throughout_chain "bind_events"

    init: ->

    engine.things.define_getter.call @, "id", ->
        return @_id

    add_id: (id) ->
        # Do not extend
        return false if @_id?
        @_id = id

    activate_method_throughout_chain: (name, args...) ->
        ###
        This will allow us to call a method at every level
        in the prototype chain so even shadowed methods
        will still be called.
        ###
        proto_chain = @
        while (proto_chain = Object.getPrototypeOf proto_chain)
            if proto_chain.hasOwnProperty(name) and
            typeof proto_chain[name] is "function"
                proto_chain[name].apply @, args

    check_for_property_chaining: (event) ->
        ###
        Whenever a property has been changed, this will be called
        to look through the prototype chain to find property chains
        and see what other properties will also have changed.

        This should not be extended.
        ###
        proto_chain = @
        while (proto_chain = Object.getPrototypeOf proto_chain)
            if proto_chain.constructor and
            property_chains = proto_chain.constructor.property_chains
                continue unless property_chains?
                chained = property_chains[event.property]
                if chained?
                    already_triggered = []
                    parent = event.parent_event
                    while parent?
                        already_triggered.push parent.property
                        parent = parent.parent_event
                    for property in chained
                        # Prevent recursive chain looping
                        continue if property in already_triggered
                        @trigger new engine.events.ThingPropertyAffected property, event

    update_property: (property) ->
        ###
        This is set to be called whenever a property is updated.
        This should not need to be extended.

        It will also check to see if a property has been set to
        the same as the default and then remove it so that the
        default can shine through. This will help keep the
        serialized form of the object smaller.
        ###
        if @hasOwnProperty "_#{property}"
            value = @["_#{property}"]
            delete @["_#{property}"]
            if JSON.stringify(value) != JSON.stringify(@["_#{property}"])
                @["_#{property}"] = value

    check_for_property_modifiers: (property, value) ->
        ###
        This method triggers the "property_accessed" event
        so that things can watch for a property to be
        accessed and then change it via the hidden variable
        that is temporarily created.

        The callbacks for property_accessed events must
        be synchronous.

        This should not be extended.
        ###
        if @_property_modifier_handlers[property]
            hidden_property_name = "__temp_" + property + "_modifier"
            @[hidden_property_name] = value
            @trigger new engine.events.Event "property_accessed",
                property        : property
                value           : value
                property_name   : hidden_property_name
            value = @[hidden_property_name]
            delete @[hidden_property_name]
        return value

    bind_property_modifier_handler: (property, handler, scope) ->
        property_modifier_handlers = @_property_modifier_handlers[property] or []
        property_modifier_handlers.push handler
        @_property_modifier_handlers[property] = property_modifier_handlers
        @on "property_accessed", handler, scope
        @trigger new engine.events.ThingPropertyAffected property

    unbind_property_modifier_handler: (property, handler) ->
        property_modifier_handlers = @_property_modifier_handlers[property]
        if property_modifier_handlers
            engine.utils.remove_val_from_array property_modifier_handlers, handler
            @_property_modifier_handlers[property] = property_modifier_handlers
        @off "property_accessed", handler
        @trigger new engine.events.ThingPropertyAffected property

    bind_events: ->
        ###
        This is called throughout the prototype chain on all things
        when they are created. This is the only time we should do
        event bindings to ourselves.
        ###
        @on "property_change", (event) =>
            @update_property event.property
            @trigger new engine.events.ThingPropertyAffected event.property
        @on "property_affected", (event) =>
            @trigger new engine.events.ThingSpecificPropertyAffected event.property
            # Check if we chain through to affect other properties
            @check_for_property_chaining event

    unbind_events: ->
        ###
        The registry triggers this throughout the prototype chain on
        all things when they are getting cached. We should remove all
        bindings when we do this.
        ###
        @off()

    registry_available: (registry) ->
        ###
        This is called throughout the prototype chain when the registry
        is made available to a thing.
        ###
        @registry = registry

    get_save_data: ->
        ###
        This is called when the object needs to be stored.
        It will return an object with all the instance's
        own properties, which it can later be recreated from.
        ###
        obj = {}
        to_exclude = [
            "_events"
            "_property_modifier_handlers"
            "registry"
        ]
        for own property, value of @
            continue if property in to_exclude
            obj[property] = value
        return obj

    remove: ->
        ###
        Any cleanup that needs to happen when
        this thing is getting completely
        removed from the game.
        ###
        @off()
