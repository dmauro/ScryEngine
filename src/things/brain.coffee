###
Brain
The brain class can be thought of as a controller for another thing.
That controller could be a player, AI, or anything that is ultimately
responsible for making choices about behavior for a thing. The host of
a brain should be a Sentient or Sentient subclass.
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

    take_turn: (action_manager, callback) ->
        ###
        This method is called by the timekeeper. This method
        must call the callback with a time that we spent doing
        our action.
        ###

        if typeof @perception_handler is "function"
            @perception_handler()
            
        @do_action action_manager, (time) =>
            @trigger new engine.events.Event "tick", {time:time}
            return callback time

    do_action: (action_manager, callback) ->
        ###
        Do any action and report back how long it takes to do it.
        We'll call this from take_turn() only. Use the action_manager
        property to do the action.
        ###
        return callback 0

    set_host: (thing_id) ->
        @host = thing_id

    get_host: (thing) ->
        return @registry.get_thing @host
