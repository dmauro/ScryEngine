class engine.things.NonPlayer extends engine.things.Brain
    @cname = "engine.things.NonPlayer"

    do_action: (action_manager, callback) ->
        # TODO: Send to personality
        # for now:
        super arguments...
