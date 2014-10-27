class engine.things.Effect extends engine.things.Abstract
    @cname = "engine.things.Effect"

    engine.things.define_defaults.call @,
        type        : null # visual, sound, smell, touch
        target      : null
        level       : 0
        duration    : false # this isn't being observed anywhere yet

    apply: (target) ->
        @_target = target.id
        target.add_effect @
        unless @_duration
            @remove target

    remove: (target) ->
        target = target or @registry.get_thing @_target
        target.remove_effect @

