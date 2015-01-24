###
ActionManager
The action manager is responsible for creating and
executing an Action for a given actor, which should
be a Brain subclass. This exists simply to make it
easier to get the world instance to the actions.
It should only be subclassed to add functionality.
###
class engine.actions.ActionManager
    constructor: (@world) ->

    do_action: (actor, action_class, data, success_callback, failure_callback) ->
        return failure_callback("Action does not exist.") unless action_class?
        action = new action_class actor.get_host(), data, @world, success_callback, failure_callback
        action.do()
