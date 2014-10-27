class engine.ui.components.TileMap extends engine.ui.components.Base
    styles: ["tile_map"]

    @::__defineGetter__ "data_source", ->
        return @_data_source

    @::__defineSetter__ "data_source", (data_source) ->
        @_data_source  = data_source
        @viewport_width = data_source.view_width * 2 * data_source.tile_width + data_source.tile_width
        @viewport_height = data_source.view_height * 2 * data_source.tile_height + data_source.tile_height

    render: ->
        @background_element = @create_element 'canvas', {id  : "#{@namespace}_background", class : "canvas_background", width: @viewport_width, height: @viewport_height}
        @lighting_element = @create_element 'canvas', {id  : "#{@namespace}_lighting", class : "canvas_lighting", width: @viewport_width, height: @viewport_height}
        @foreground_element = @create_element 'canvas', {id  : "#{@namespace}_foreground", class : "canvas_foreground", width: @viewport_width, height: @viewport_height}
        @composite_element = @create_element 'canvas', {id  : "#{@namespace}_composite", class : "canvas_composite", width: @viewport_width, height: @viewport_height}
        return @create_element 'div', @composite_element

    has_appeared: ->
        animation_loop = =>
            window.requestAnimationFrame =>
                if @should_draw_map
                    @should_draw_map = false
                    @_draw_map()
                animation_loop()
        animation_loop()

    draw_map: ->
        @should_draw_map = true

    _draw_map: ->
        # Update canvas sizes and positions
        center_x = @data_source.center_x
        center_y = @data_source.center_y
        z = @data_source.z

        center_x_diff = @center_x - center_x
        center_y_diff = @center_y - center_y
        did_z_change = z isnt @z

        @center_x = center_x
        @center_y = center_y
        @z = z

        # Drawing
        bounds =
            top     : @center_y - @data_source.view_height
            bottom  : @center_y + @data_source.view_height
            left    : @center_x - @data_source.view_width
            right   : @center_x + @data_source.view_width
        light_updates = @data_source.update_light_map bounds
        # Find out which bg tiles need drawing based on exposure
        @draw_background center_x_diff, center_y_diff, did_z_change
        @draw_foreground()
        # Find out which tiles had a change in lighting
        @draw_lighting center_x_diff, center_y_diff, did_z_change, light_updates
        # Sprites we can just completely redraw
        @draw_composite()

    draw_background: (x_diff, y_diff, did_z_change) ->
        background_context = @background_element.getContext "2d"

        # Get some variables we'll reuse a lot
        data_source = @data_source
        view_width = data_source.view_width
        view_height = data_source.view_height
        tile_width = data_source.tile_width
        tile_height = data_source.tile_height

        # Shift the image by the position diff
        unless did_z_change
            background_context.drawImage @background_element, x_diff * tile_width, y_diff * tile_height

        # Then draw the rest
        rel_x = 0
        rel_y = 0
        left = @center_x - view_width
        right = @center_x + view_width
        top = @center_y - view_height
        bottom = @center_y + view_height
        for y in [top..bottom]
            for x in [left..right]
                if did_z_change or
                rel_x < x_diff or rel_x > view_width * 2 + x_diff or
                rel_y < y_diff or rel_y > view_height * 2 + y_diff
                    tile = data_source.get_tile_at x, y
                    # TODO: A proper way to get colors
                    color = "#000"
                    if tile
                        if tile.constructor.cname is "engine.geography.tiles.Floor"
                            color = "#AAA"
                        else if tile.constructor.cname is "engine.geography.tiles.Wall"
                            color = "#844"
                    background_context.fillStyle = "rgba(#{engine.utils.hex_to_rgb color}, 1)"
                    background_context.fillRect rel_x * tile_width, rel_y * tile_height, tile_width, tile_height
                rel_x += 1
                if rel_x >= view_width * 2 + 1
                    rel_x = 0
            rel_y += 1
        return

    draw_foreground: ->
        # TEMP: Just drawing the hero in the center as a single block for now...
        foreground_context = @foreground_element.getContext "2d"
        foreground_context.fillStyle = "rgba(#{engine.utils.hex_to_rgb '#00FF00'}, 1)"
        console.log "FILL STYLE: #{foreground_context.fillStyle}"
        foreground_context.fillRect @data_source.view_width * @data_source.tile_width, @data_source.view_height * @data_source.tile_height, @data_source.tile_width, @data_source.tile_height

    draw_lighting: (x_diff, y_diff, did_z_change, updated) ->
        lighting_context = @lighting_element.getContext "2d"

        # Get some variables we'll reuse a lot
        data_source = @data_source
        view_width = data_source.view_width
        view_height = data_source.view_height
        tile_width = data_source.tile_width
        tile_height = data_source.tile_height

        # Naively update every tile
        for y in [0...@viewport_height/tile_height]
            for x in [0...@viewport_width/tile_width]
                global_x = x + (@center_x - view_width)
                global_y = y + (@center_y - view_height)
                visibility = data_source.visibility_at_point global_x, global_y
                opacity = 1 - visibility
                lighting_context.clearRect x * tile_width, y * tile_height, tile_width, tile_height
                # Darkness
                if opacity > 0
                    lighting_context.globalCompositeOperation = "source-over"
                    lighting_context.fillStyle = "rgba(0, 0, 0, #{opacity})"
                    lighting_context.fillRect x * tile_width, y * tile_height, tile_width, tile_height
                # Light
                if visibility > 0
                    color = data_source.light_color_at_point global_x, global_y
                    color = engine.utils.hex_to_rgb color
                    lighting_context.globalCompositeOperation = "lighten"
                    lighting_context.fillStyle = "rgba(#{color}, 1)"
                    lighting_context.fillRect x * tile_width, y * tile_height, tile_width, tile_height
        return

        ###
        # Shift the image by the position diff
        unless did_z_change
            image = new Image()
            image.src = @lighting_element.toDataURL "image/png"
            lighting_context.clearRect 0, 0, @viewport_width, @viewport_height
            lighting_context.drawImage image, x_diff * tile_width, y_diff * tile_height

        lighting_context.fillStyle = "rgba(0, 0, 0, 1)"
        if did_z_change
            lighting_context.fillRect 0, 0, @viewport_width, @viewport_height

        # Fill in any new tiles just pushed on screen
        else
            draw_at = (x, y) =>
                global_x = x + (@center_x - view_width)
                global_y = y + (@center_y - view_height)
                visibility = data_source.visibility_at_point global_x, global_y
                #visibility = adjust_visibility_for_memory visibility, global_x, global_y
                opacity = 1 - visibility
                lighting_context.fillStyle = "rgba(0, 0, 0, #{opacity})"
                lighting_context.fillRect x * tile_width, y * tile_height, tile_width, tile_height

            # Tiles left and right
            left = if (x_diff > 0) then 0 else @viewport_width/tile_width + x_diff
            right = if (x_diff > 0) then x_diff else @viewport_width/tile_width
            for y in [0...@viewport_height/tile_height]
                for x in [left...right]
                    draw_at x, y

            # Tiles above and below
            top = if (y_diff > 0) then 0 else @viewport_height/tile_height + y_diff
            bottom = if (y_diff > 0) then y_diff else @viewport_height/tile_height
            left = if (x_diff > 0) then x_diff else 0
            right = if (x_diff > 0) then @viewport_width/tile_width else @viewport_width/tile_width + x_diff
            for y in [top...bottom]
                for x in [left...right]
                    draw_at x, y

        # Then change any that have been updated
        for update in updated
            x = update.x
            y = update.y
            visibility = data_source.visibility_at_point x, y, update.amount
            #visibility = adjust_visibility_for_memory visibility, x, y
            opacity = 1 - visibility
            rel_x = x - (@center_x - view_width)
            rel_y = y - (@center_y - view_height)
            lighting_context.clearRect rel_x * tile_width, rel_y * tile_height, tile_width, tile_height
            lighting_context.fillStyle = "rgba(0, 0, 0, #{opacity})"
            lighting_context.fillRect rel_x * tile_width, rel_y * tile_height, tile_width, tile_height
        return
        ###

    draw_composite: ->
        composite_context = @composite_element.getContext "2d"
        composite_context.globalCompositeOperation = "source-over"
        # Drawing the background will suffice instead of clearRect
        composite_context.drawImage(@background_element, 0, 0)
        composite_context.drawImage(@foreground_element, 0, 0)
        composite_context.globalCompositeOperation = "multiply"
        composite_context.drawImage(@lighting_element, 0, 0)
