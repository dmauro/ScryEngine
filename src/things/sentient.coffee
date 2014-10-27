class engine.things.Sentient extends engine.things.Sprite
    @cname = "engine.things.Sentient"

    engine.things.define_defaults.call @,
        brain   : null

    give_sentience: (brain) ->
        @brain = brain.id
        brain.set_host @id
        return
