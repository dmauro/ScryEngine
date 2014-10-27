###
A 2D array for storing things with dynamic
height and width. This is an Array-like object
###

class engine.utils.MatrixArray
    @::__defineGetter__ "length", ->
        length = 0
        for own x, ys of @
            for own y, value of ys
                length += 1
        return length

    @::__defineGetter__ "width", ->
        max_left = Infinity
        max_right = -Infinity
        for own x, ys of @
            x = parseInt x, 10
            max_left = x if x < max_left
            max_right = x if x > max_right
        difference = Math.abs max_right - max_left
        width = if difference is -Infinity then 0 else difference

    @::__defineGetter__ "height", ->
        max_top = Infinity
        max_bottom = -Infinity
        for own x, ys of @
            for own y, value of ys
                y = parseInt y, 10
                max_top = y if y < max_top
                max_bottom = y if y > max_bottom
        difference = Math.abs max_bottom - max_top
        width = if difference is -Infinity then 0 else difference

    constructor: (data) ->
        # We can pass in an array for restoring
        for own x, ys of data
            @[x] = {}
            for own y, value of ys
                @[x][y] = value
        return

    for_each: (handler) ->
        for own x, ys of @
            for own y, value of ys
                handler value, x * 1, y * 1
        return

    set_value_at: (x, y, value) ->
        @[x] = {} unless @[x]?
        @[x][y] = value

    get_value_at: (x, y) ->
        return @[x]?[y]

    remove_value_at: (x, y) ->
        delete @[x][y]
        length = 0
        for own y, value of @[x]
            length += 1
            break
        delete @[x] unless length

    get_save_data: (handler) ->
        # If you pass in a handler it should
        # return the value you want saved at 
        # each location in the array.
        save_data = {}
        for own x, ys of @
            save_data[x] = {}
            for own y, value of ys
                if typeof handler is "function"
                    save_data[x][y] = handler value, x, y
                else
                    save_data[x][y] = value
        return save_data
