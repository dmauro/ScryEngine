# TODO: Remove these subclasses, not helpful
# If we can come up with a better way to associate key value pairs
# This works for now

class engine.events.ThingPropertyChange extends engine.events.Event
    constructor: (property, args...) ->
        super "property_change", {property:property}, args...

class engine.events.ThingPropertyAffected extends engine.events.Event
    constructor: (property, args...) ->
        super "property_affected", {property:property}, args...

class engine.events.ThingSpecificPropertyAffected extends engine.events.Event
    constructor: (property, args...) ->
        super "#{property}_property_affected", args...

class engine.events.SpriteMoved extends engine.events.Event
    constructor: (x, y, z, prev_x, prev_y, prev_z, args...) ->
        super "sprite_moved", {x:x, y:y, z:z, prev_x:prev_x, prev_y:prev_y, prev_z:prev_z}, args...

class engine.events.EffectApplied extends engine.events.Event
    event_name: "effect_applied"
    constructor: (effect, args...) ->
        super @event_name, {effect:effect}, args...
