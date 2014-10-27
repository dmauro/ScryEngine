class engine.events.Base
    constructor: (@name, data={}, @parent_event) ->
        for own key, value of data
            throw new Error "Trying to override a reserved event property: #{key}" if @key?
            @[key] = value

    get_root_event: ->
        parent = @
        while parent.parent_event?
            parent = parent.parent_event
        return parent

    get_callstack: ->
        root = @get_root_event
        return root.callstack or root.callstack = []

class engine.events.ThingPropertyChange extends engine.events.Base
    constructor: (property, args...) ->
        super "property_change", {property:property}, args...

class engine.events.ThingPropertyAffected extends engine.events.Base
    constructor: (property, args...) ->
        super "property_affected", {property:property}, args...

class engine.events.ThingSpecificPropertyAffected extends engine.events.Base
    constructor: (property, args...) ->
        super "#{property}_affected", args...

class engine.events.SpriteMoved extends engine.events.Base
    constructor: (x, y, z, prev_x, prev_y, prev_z, args...) ->
        super "sprite_moved", {x:x, y:y, z:z, prev_x:prev_x, prev_y:prev_y, prev_z:prev_z}, args...
