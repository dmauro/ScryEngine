###
The Atlas tracks tiles that have
been exposed. This is used to help
show what a Brain class has seen of
the world.

Currently unused, may not want historical mapping.
###

class engine.geography.Atlas
    @::__defineGetter__ "width", ->
        Math.abs(@max_x - @min_x) + 1

    @::__defineGetter__ "height", ->
        Math.abs(@max_y - @min_y) + 1

    constructor: (data) ->
        if data?
            @_restore()
        else
            @_init()

    _restore: (data) ->
        @min_x = data.min_x
        @max_x = data.max_x
        @min_y = data.min_y
        @max_y = data.max_y
        @exposed_x = data.exposed_x
        @exposed_y = data.exposed_y

    _init: ->
        @min_x = Infinity
        @max_x = -Infinity
        @min_y = Infinity
        @max_y = -Infinity
        @exposed_x = []
        @exposed_y = []

    is_coordinate_exposed: (x, y) ->
        for i in [0...@exposed_x.length]
            return true if @exposed_x[i] is x and @exposed_y[i] is y
        return false

    expose_coordinate: (x, y) ->
        unless @is_coordinate_exposed x, y
            @exposed_x.push x
            @exposed_y.push y
            if x > max_x
                max_x = x
            else if x < min_x
                min_x = x
            if y > max_y
                max_y = y
            else if y < min_y
                min_y = y

    is_exposed_at_coordinate: (x, y) ->
        return true if x in @exposed_x and y in @exposed_y
        return false

    get_save_data: ->
        save_data =
            min_x       : @min_x
            max_x       : @max_x
            min_y       : @min_y
            max_y       : @max_y
            exposed_x   : @exposed_x
            exposed_y   : @exposed_y
        return save_data
