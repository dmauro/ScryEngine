###
Effect
This represents some kind of change to how a target Sprite
is perceived by one of the senses.
###
class engine.things.Effect extends engine.things.Abstract
    @cname = "engine.things.Effect"

    engine.things.define_defaults.call @,
        type            : null # visual, sound, smell, touch
        target          : null
        level           : 0
        is_immediate    : false

    apply: (target) ->
        @_target = target.id
        target.add_effect @
        if @is_immediate
            @remove target

    remove: (target) ->
        target = target or @registry.get_thing @_target
        target.remove_effect @

