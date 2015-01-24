###
Brain
The brain class can be thought of as a controller for another thing.
That controller could be a player, AI, or anything that is ultimately
responsible for making choices about behavior for a thing.
###
class engine.things.Brain extends engine.things.Thing
    @cname = "engine.things.Brain"
    
    engine.things.define_defaults.call @,
        host    : null
        senses  :
            sight   : 10
            smell   : 0
            hearing : 0
            touch   : 1

    take_turn: (callback) ->
        @do_action (time) =>
            @trigger new engine.events.Event "tick", {time:time}
            return callback time

    do_action: (callback) ->
        # Do any action and report back how long it takes to do
        return callback 0

    set_host: (thing_id) ->
        @host = thing_id

    get_host: (thing) ->
        return @registry.get_thing @host
