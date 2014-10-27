############################
# Helper Utility Functions #
############################

# TODO: Clean this up a bit. Move map utilities out, this should be more generic.

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

engine.utils.constructor_from_string = (class_string) ->
    class_array = class_string.split "."
    constructor = engine
    # Pop off the existing "engine"
    class_array.shift()
    while class_array.length
        constructor = constructor[class_array.shift()]
    return constructor

engine.utils.generate_uuid = (random) ->
    #RFC4122 v4 Random UUID
    uuid = ""
    for i in [0...32]
        r = random() * 16 | 0
        if i in [8, 12, 16, 20]
            uuid += "-"
        uuid += (if i is 12 then 4 else if i is 16 then (r & 3 or 8) else r).toString 16
    return uuid

engine.utils.combine_arrays = ->
    array = []
    for a in arguments
        for value in a
            array.push value
    return array

engine.utils.compare_arrays = (a1, a2) ->
    ###
    This will ignore the ordering of the arrays
    and simply check if they have the same contents.

    This isn't perfect as for example these two 
    arrays would evaluate as being the same:
    ["apple", "orange", "orange"], ["orange", "apple", "apple"]
    But it will serve for now.
    ###
    return false unless a1.length is a2.length
    for item in a1
        continue if item in a2
        return false
    for item in a2
        continue if item in a1
        return false
    return true

engine.utils.remove_val_from_array = (array, value) ->
    # Alters the original array
    return false unless array and value?
    array[t..t] = [] if (t = array.indexOf(value)) > -1
    return array

engine.utils.subtract_arrays = (a1, a2) ->
    sum = []
    for value in a1
        sum.push value
    for value in a2
        engine.utils.remove_val_from_array sum, value
    return sum

engine.utils.array_from_dict_keys = (dict) ->
    a = []
    for k, v of dict
        a.push k
    return a

engine.utils.roll = (die_roll = "1d20", should_return_array = false) ->
    num = parseInt die_roll.slice(0, die_roll.indexOf("d")), 10
    sides = parseInt die_roll.slice(die_roll.indexOf("d") + 1), 10
    rolls = []
    for i in [0..num-1]
        rolls.push Math.floor(game.random()*sides) + 1
    if should_return_array
        return rolls
    else
        total = 0
        for v in rolls
            total += v
        return total
        
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

engine.utils.tiles_are_touching = (t1, t2) ->
    return true if (Math.abs(t1.x - t2.x) <= 1 and t1.y is t2.y) or (Math.abs(t1.y - t2.y) <= 1 and t1.x is t2.x)

engine.utils.get_tiles_between = (target_tile, start_tile, check_los=false) ->
    ###
    Get all the tiles between two points. If we check for line of sight,
    then we simply return true or false. Otherwise we return the array
    of tiles
    ###
    map = game.current_map
    x1 = target_x = target_tile.x
    y1 = target_y = target_tile.y
    x2 = start_tile.x
    y2 = start_tile.y
    if check_los
        target_is_impassable = target_tile.is_impassable
        angle = Math.atan2(y2 - y1, x2 - x1)/Math.PI
    else
        tiles = []
    dx = Math.abs x2 - x1
    dy = Math.abs y2 - y1
    sx = if x1 < x2 then 1 else -1
    sy = if y1 < y2 then 1 else -1
    err = dx - dy
    while not (x1 is x2 and y1 is y2)
        e2 = err << 1
        if e2 > -dy
            err -= dy
            x1 += sx
        if e2 < dx
            err += dx
            y1 += sy
        tile = map.get_tile_at x1, y1

        # If we're not worried about line of sight we just add the tile 
        if !check_los
            tiles.push tile
            continue

        # Otherwise we're just checking if it's impassable
        if check_los and tile.is_impassable
            # Conditional to check if this could be a wall at an extreme angle
            if target_is_impassable and engine.utils.tiles_are_adjacent {x:target_x, y:target_y}, {x:x1, y:y1}
                x_diff = x1 - target_x
                y_diff = y1 - target_y
                if x_diff is 1 and y_diff is 0
                    continue if -0.5 < angle < 0 and not map.get_tile_at(target_x + 1, target_y - 1).is_impassable
                    continue if 0 < angle < 0.5 and not map.get_tile_at(target_x + 1, target_y + 1).is_impassable
                else if x_diff is -1 and y_diff is 0
                    continue if -1 < angle < -0.5 and not map.get_tile_at(target_x - 1, target_y - 1).is_impassable
                    continue if 0.5 < angle < 1 and not map.get_tile_at(target_x - 1, target_y + 1).is_impassable
                else if x_diff is 0 and y_diff is 1
                    continue if 0 < angle < 0.5 and not map.get_tile_at(target_x + 1, target_y + 1).is_impassable
                    continue if 0.5 < angle < 1 and not map.get_tile_at(target_x - 1, target_y + 1).is_impassable
                else if x_diff is 0 and y_diff is -1
                    continue if -0.5 < angle < 0 and not map.get_tile_at(target_x + 1, target_y - 1).is_impassable
                    continue if -1 < angle < -0.5 and not map.get_tile_at(target_x - 1, target_y - 1).is_impassable
            # Otherwise this tile is blocking us
            return false

    return true if check_los
    return tiles

engine.utils.has_los = (target_tile, start_tile) ->
    if engine.utils.get_tiles_between target_tile, start_tile, true
        return true
    return false
    
engine.utils.get_tiles_within_radius = (point, radius, should_check_for_los) ->
    map = game.current_map
    x1 = point[0]
    y1 = point[1]
    within = []
    smooth_radius = radius + 0.25
    for y in [y1-radius..y1+radius]
        for x in [x1-radius..x1+radius]
            distance = engine.utils.get_distance_between_points point, [x, y]
            continue if distance > smooth_radius
            tile = map.get_tile_at x, y
            continue if !tile or tile.type in ["empty", "solid"]
            if x is x1 and y is y1
                within.push tile
                continue
            continue if !tile or tile.type in ["empty", "solid"]
            within.push tile if !should_check_for_los or engine.utils.has_los tile, {x:x1,y:y1}
    return within

engine.utils.get_distance_between_points = (p1, p2) ->
    return Math.sqrt(((p1[0] - p2[0])*(p1[0] - p2[0])) + ((p1[1] - p2[1])*(p1[1] - p2[1])))

engine.utils.get_distance_between_in_feet = ->
    return engine.utils.get_distance_between(arguments...) * 5

engine.utils.get_distance_between = (t1, t2) ->
    t1_width = t1.width
    t1_height = t1.height
    t2_width = t2.width
    t2_height = t2.height
    t1_x = t1.x
    t1_y = t1.y
    t2_x = t2.x
    t2_y = t2.y
    if t1_width or t1_height or t2_width or t2_height
        # We have to do more advanced distance finding for large things
        x_distance = t1_x - t2_x
        y_distance = t1_y - t2_y
        if x_distance > 0 and t2_width
            t2_x += t2_width - 1
        else if x_distance < 0 and t1_width
            t1_x += t1_width - 1
        if y_distance > 0 and t2_height
            t2_y += t2_height - 1
        else if y_distance < 0 and t1_height
            t1_y += t1_height - 1
    return engine.utils.get_distance_between_points [t1_x, t1_y], [t2_x, t2_y]
    
engine.utils.tiles_are_adjacent = (t1, t2) ->
    return true if Math.abs(t1.x - t2.x) <= 1 and Math.abs(t1.y - t2.y) <= 1

engine.utils.sprites_are_adjacent = (s1, s2, forced_width=null, forced_height=null) ->
    width = forced_width or s1.width or 1
    height = forced_height or s1.height or 1
    s2_width = s2.width
    s2_height = s2.height
    if width > 1 or height > 1 or s2_width or s2_height
        # Sprites are adjacent if distance is less than 2
        return engine.utils.get_distance_between({
            x       : s1.x
            y       : s1.y
            width   : width
            height  : height
        }, {
            x       : s2.x
            y       : s2.y
            width   : s2_width
            height  : s2_height
        }) < 2;
    else
        return engine.utils.tiles_are_adjacent s1, s2

engine.utils.sprite_can_fit_tile = (sprite, tile) ->
    width = sprite.width
    height = sprite.height
    unless width or height
        return true
    engine.utils.size_can_fit width, height, tile.x, tile.y

engine.utils.size_can_fit = (width, height, x, y) ->
    map = game.current_map
    can_fit = true
    for y2 in [y...y + height]
        for x2 in [x...x + width]
            adjacent_tile = map.get_tile_at x2, y2
            if adjacent_tile.is_impassable
                can_fit = false
                break
    return can_fit
    
engine.utils.get_path_between = (t1, t2, height=1, width=1, max_distance=0) ->
    # Return an array of tiles between two things
    if height > 1 or width > 1
        path = pathfinding.get_astar_path arguments...
    else
        path = pathfinding.get_jps_path arguments...
    return path
