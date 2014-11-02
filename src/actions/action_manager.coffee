class engine.actions.ActionManager
    constructor: (@world) ->

    do_action: (actor, action_class, data, success_callback, failure_callback) ->
        return failure_callback("Action does not exist.") unless action_class?
        action = new action_class actor.get_host(), data, @world, success_callback, failure_callback
        action.do()
