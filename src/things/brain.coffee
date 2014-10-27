class engine.things.Brain extends engine.things.Base
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
            @trigger new engine.events.Base "tick", {time:time}
            return callback time

    do_action: (callback) ->
        # Do any action and report back how long it takes to do
        return callback 0

    set_host: (thing_id) ->
        @host = thing_id

    get_host: (thing) ->
        return @registry.get_thing @host
