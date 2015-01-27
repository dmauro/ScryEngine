###
PlayerPlayback
This is the sentience used to control a host that is being
controlled with a players past inputs. Used for game playback.
###
class engine.things.PlayerPlayback extends engine.things.Player
    @cname = "engine.things.PlayerPlayback"

    init: ->
        @index = 0

    do_action: (action_manager, callback) ->
        history_tuple = @game_history.get_history_at_index @index
        if history_tuple
            action_class = history_tuple[0]
            data = history_tuple[1]
            # Make sure to pause at each step
            setTimeout(=>
                action_manager.do_action @, action_class, data, (time) =>
                    callback time
                , (error_message) =>
                    console.log "Error executing playback history with class:\n#{action_class}\nand data:\n#{data}"
                @index += 1
            , 50)
        else
            console.log "Playback is all done"
