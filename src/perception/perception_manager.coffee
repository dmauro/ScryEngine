###
This class will be in charge of tracking
when things get to make active or passive
spot checks. It will ask the things to
make a spot check supplying the spot
type and distance.

It will also be in charge of telling the
thing how well it perceived the thing
it was making a spot check against.
###

class engine.perception.PerceptionManager
    constructor: (action_manager) ->
        BrainManager = @constructor_for_name "brain_manager"
        @brain_manager = new BrainManager()
        @brain_manager.brain_added_handler = (brain) =>
            brain.action_manager = action_manager

    constructor_for_name: (name) ->
        switch name
            when "brain_manager"
                return engine.BrainManager

    bind_to_registry: (registry) ->
        @registry = registry
        @brain_manager.bind_to_registry registry

    # Function to get


