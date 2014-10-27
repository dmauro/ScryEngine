class engine.things.Player extends engine.things.Brain
    @cname = "engine.things.Player"

    # Placeholder player response to wait for player input
    do_action: (callback) ->
        @offerred_turn_handler()
        @listen_for_actions_handler callback, (error_message) =>
            # In case of failure, give the player back control
            console.log "Error completing action:", error_message
            @do_action callback

