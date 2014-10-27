class engine.actions.Walk extends engine.actions.Move
    _fail_if_movement_is_invalid: (x_diff, y_diff) ->
        # Movement must be to an adjacent location
        if x_diff is 0 and y_diff is 0
            @failure_callback "You cannot move to the same position you are currently on."
        else if not ((x_diff or y_diff) and -1 <= x_diff <= 1 and -1 <= y_diff <= 1)
            @failure_callback "You must move to an adjacent location"

    _get_time_to_complete: ->
        # Placeholder
        return @time * (@actor.speed or 1)

    do: ->
        x_diff = Math.abs @data.x
        y_diff = Math.abs @data.y

        @_fail_if_movement_is_invalid x_diff, y_diff

        # Get the base time to complete
        if (x_diff is 1 and y_diff isnt 1) or (x_diff isnt 1 and y_diff is 1)
            @time = 1
        else
            @time = 1.4

        # Simulate time here to do an animation
        setTimeout =>
            super()
        , 100
