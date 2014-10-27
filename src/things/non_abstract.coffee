class engine.things.NonAbstract extends engine.things.Base
    @cname = "engine.things.NonAbstract"
    
    engine.things.define_defaults.call @,
        x   : null # Int
        y   : null # Int
        z   : null # Int

    engine.things.define_getter.call @, "x", ->
        return @_x if @_x?
        return @_owner.x if @_owner?

    engine.things.define_getter.call @, "y", ->
        return @_y if @_y?
        return @_owner.y if @_owner?

    engine.things.define_getter.call @, "z", ->
        return @_z if @_z?
        return @_owner.z if @_owner?

    ###
    Below: still in progress
    ###

    change_constructor: (constructor) ->
        # Explore this for polymorphing
        return new constructor @get_save_data()
