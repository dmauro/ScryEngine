###
Move -> Action
A basic action to handle the common use case of moving
a sprite from one tile to another while checking that
the actor is able to do so.
###
class engine.actions.Move extends engine.actions.Action
    @cname = "engine.actions.Move"

    _tile_is_impassable: ->
        unless @actor.incorporeal
            @failure_callback "You cannot enter that tile"
            return true
        return false

    _tile_is_obstacle: ->
        unless @actor.is_flying
            @failure_callback "You cannot enter that tile"
            return true
        return false

    _thing_is_in_target_location: (other_thing) ->
        return @failure_callback "Something is already on that tile"

    do: ->
        target_x = @actor.x + @data.x
        target_y = @actor.y + @data.y

        tile = @world.get_tile_at target_x, target_y
        return if @_tile_is_impassable() if tile.is_impassable
        return if @_tile_is_obstacle() if tile.is_obstacle

        things_on_tile = @registry.get_things_with_position target_x, target_y
        for other_thing in things_on_tile
            return if @_thing_is_in_target_location other_thing

        @actor.move_to target_x, target_y

        super()
