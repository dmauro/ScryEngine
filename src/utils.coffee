############################
# Helper Utility Functions #
############################

# This function needs the root object to build everything
((root) ->
    engine.utils.constructor_from_string = (class_string) ->
        class_array = class_string.split "."

        # For testing out of browser
        if root and window? and root is window
            constructor = root
        else if exports
            constructor = exports
            class_array.shift()

        while class_array.length
            constructor = constructor[class_array.shift()]
        return constructor
)(this)

engine.utils.create_from_constructor_string = (string, args...) ->
    constructor = engine.utils.constructor_from_string string
    instance = new constructor args...
    return instance

engine.utils.multiply_hex_number = (hex, multiplier) ->
    r = parseInt hex.substr(0, 2), 16
    g = parseInt hex.substr(2, 2), 16
    b = parseInt hex.substr(4, 2), 16
    white = "FF"
    r = Math.round r * multiplier
    r = r.toString 16
    if r.length > 2
        r = "ff"
    while r.length < 2
        r = "0#{r}"
    g = Math.round g * multiplier
    g = g.toString 16
    if g.length > 2
        g = "ff"
    while g.length < 2
        g = "0#{g}"
    b = Math.round b * multiplier
    b = b.toString 16
    if b.length > 2
        b = "ff"
    while b.length < 2
        b = "0#{b}"
    return "#{r}#{g}#{b}"

engine.utils.add_hex_numbers = (hex_1, hex_2) ->
    string = (parseInt(hex_1, 16) + parseInt(hex_2, 16)).toString(16)
    return string

engine.utils.add_hex_colors = (color_1, color_2) ->
    red = engine.utils.add_hex_numbers color_1.substr(0, 2), color_2.substr(0, 2)
    if red.length > 2
        red = "ff"
    while red.length < 2
        red = "0#{red}"
    green = engine.utils.add_hex_numbers color_1.substr(2, 2), color_2.substr(2, 2)
    if green.length > 2
        green = "ff"
    while green.length < 2
        green = "0#{green}"
    blue = engine.utils.add_hex_numbers color_1.substr(4, 2), color_2.substr(4, 2)
    if blue.length > 2
        blue = "ff"
    while blue.length < 2
        blue = "0#{blue}"
    return "#{red}#{green}#{blue}"
        
engine.utils.hex_to_rgb = (hex) ->
    hex = hex.substr 1 unless hex.length in [3, 6]
    if hex.length is 3
        r = parseInt hex.substr(0,1) + hex.substr(0,1), 16
        g = parseInt hex.substr(1,1) + hex.substr(1,1), 16
        b = parseInt hex.substr(2,1) + hex.substr(2,1), 16
    else if hex.length is 6
        r = parseInt hex.substr(0,2), 16
        g = parseInt hex.substr(2,2), 16
        b = parseInt hex.substr(4,2), 16
    return [r, g, b]

engine.utils.deep_extend = (target) ->
    for dictionary in arguments
        continue if dictionary is target
        for own property, value of dictionary
            if typeof value is "object"
                # This makes it work better than jQuery's extend
                # but is problematic for arrays.
                # TODO: Check this doesn't break with arrays
                target[property] = target[property] or {}
                engine.utils.deep_extend target[property], value
            else
                target[property] = value
    return target

engine.utils.generate_uuid = (random) ->
    #RFC4122 v4 Random UUID
    uuid = ""
    for i in [0...32]
        r = random() * 16 | 0
        if i in [8, 12, 16, 20]
            uuid += "-"
        uuid += (if i is 12 then 4 else if i is 16 then (r & 3 or 8) else r).toString 16
    return uuid

engine.utils.remove_val_from_array = (array, value) ->
    # Alters the original array
    return false unless array and value?
    array[t..t] = [] if (t = array.indexOf(value)) > -1
    return array

engine.utils.roll = (die_roll = "1d20", random, should_return_array = false) ->
    num = parseInt die_roll.slice(0, die_roll.indexOf("d")), 10
    sides = parseInt die_roll.slice(die_roll.indexOf("d") + 1), 10
    rolls = []
    for i in [0..num-1]
        rolls.push Math.floor(random()*sides) + 1
    if should_return_array
        return rolls
    else
        total = 0
        for v in rolls
            total += v
        return total

engine.utils.get_direction_between_points = (p1, p2) ->
    ###
    This will give us the cardinal direction
    from p1 to p2. Anything that is not exactly
    N,S,E, or W will be NE, NW, SE, or SW.
    ###
    x_diff = p2[0] - p1[0]
    y_diff = p2[1] - p1[1]
    if x_diff > 0
        if y_diff > 0
            return "SE"
        if y_diff < 0
            return "NE"
        if y_diff == 0
            return "E"
    if x_diff < 0
        if y_diff > 0
            return "SW"
        if y_diff < 0
            return "NW"
        if y_diff == 0
            return "W"
    if x_diff == 0
        if y_diff > 0
            return "S"
        if y_diff < 0
            return "N"
        if y_diff == 0
            return false
    return false

engine.utils.points_are_touching = (t1, t2) ->
    return (Math.abs(t1.x - t2.x) <= 1 and t1.y is t2.y) or (Math.abs(t1.y - t2.y) <= 1 and t1.x is t2.x)
    
engine.utils.points_are_adjacent = (t1, t2) ->
    return Math.abs(t1.x - t2.x) <= 1 and Math.abs(t1.y - t2.y) <= 1

engine.utils.get_distance_between_points = (p1, p2) ->
    return Math.sqrt(((p1[0] - p2[0])*(p1[0] - p2[0])) + ((p1[1] - p2[1])*(p1[1] - p2[1])))
