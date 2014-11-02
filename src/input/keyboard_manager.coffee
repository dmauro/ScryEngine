###
This is a helper class that actually handles
the management of keybindings for a specific
layer in the keyboard input heirarchy.
###

class engine.input.KeyboardInputLayer
    constructor: (element) ->
        @is_on = true
        # is_blocking prevents layers below from receiving key inputs
        @is_blocking = true
        if keypress?
            @bindings = new keypress.Listener element

    bind_actions: (key_bindings) ->
        if keypress?
            @bindings.reset()
            for keys, handler of key_bindings
                @bindings.simple_combo keys, handler

    on: ->
        return if @is_on
        @is_on = true
        if keypress?
            @bindings.listen()

    off: ->
        return unless @is_on
        @is_on = false
        if keypress?
            @bindings.stop_listening()

##########################
# Keyboard Input Manager #
##########################

###
This class will be in charge of interfacing with
the library used for capturing keyboard input.
It will also be in charge of handling modal input
priority.
###

class engine.input.KeyboardManager
    constructor: ->
        @_layers = []

    _create_layer: (element) ->
        return new engine.input.KeyboardInputLayer element

    _adjust_layer_statuses: ->
        # This will turn all layers on or off depending
        # on if something is blocking them.
        is_blocking = false
        for layer in @_layers by -1
            if is_blocking
                layer.off()
            else
                layer.on()
                is_blocking = layer.is_blocking

    bind_input_layer: (key_bindings, is_blocking = true, element) ->
        layer = @_create_layer element
        layer.bind_actions key_bindings
        layer.is_blocking = is_blocking
        if is_blocking
            for other_layer in @_layers
                other_layer.off()
        @_layers.push layer
        return layer

    remove_layer: (layer) ->
        index = @_layers.indexOf layer
        if index is -1
            return false
        @_layers[index..index] = []
        @_adjust_layer_statuses()
        return true
