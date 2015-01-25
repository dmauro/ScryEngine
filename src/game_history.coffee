###
GameHistory
This tracks the action history for a game so that it can
be reproduced later. Because the random elements are all
seeded, this should only be required to record player
actions.
###
class engine.GameHistory
    constructor: (data) ->
        if data?
            @_restore data
        else
            @_init()

    _init: ->
        @history = []
        @action_cnames = []

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"
        @history = data.history
        @action_cnames = data.action_cnames

    get_save_data: ->
        return {
            history         : @history
            action_cnames   : @action_cnames
        }

    add_action: (action_class, data) ->
        # We're not using a ConstructorManager because we only
        # need to store the constructor, not its state data.
        cid = @action_cnames.indexOf action_class.cname
        if cid is -1
            @action_cnames.push action_class.cname
            cid = @action_cnames.length - 1
        # Push as a tuple
        @history.push [cid, data]

    get_history_at_index: (index) ->
        if index < @history.length
            tuple = @history[index]
            cid = tuple[0]
            data = tuple[1]
            action_class = engine.utils.constructor_from_string @action_cnames[cid]
            return [action_class, data]
