# TODO: Remove these subclasses, not helpful

class engine.events.ThingPropertyChange extends engine.events.Event
    constructor: (property, args...) ->
        super "property_change", {property:property}, args...

class engine.events.ThingPropertyAffected extends engine.events.Event
    constructor: (property, args...) ->
        super "property_affected", {property:property}, args...

class engine.events.ThingSpecificPropertyAffected extends engine.events.Event
    constructor: (property, args...) ->
        super "#{property}_affected", args...

class engine.events.SpriteMoved extends engine.events.Event
    constructor: (x, y, z, prev_x, prev_y, prev_z, args...) ->
        super "sprite_moved", {x:x, y:y, z:z, prev_x:prev_x, prev_y:prev_y, prev_z:prev_z}, args...
