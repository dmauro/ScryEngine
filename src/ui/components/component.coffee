###
Component
This is the base UI component class that handles the
presentation logic for a UI component.
###
class engine.ui.components.Component
    styles: []

    constructor: (@parent_component) ->
        @namespace = "ns_" + engine.utils.generate_uuid Math.random
        @sub_components = []
        @init()

    init: ->

    show: (callback, skip_animation=false) ->
        unless @element
            @element = @render()
            # Add the Namespace as ID
            @element.id = "#{@namespace}"
            # And style names as classes
            class_string = ""
            for style in @styles
                class_string += "#{style} "
            @element.className = class_string
            $(window).on "resize.#{@namespace}", =>
                @window_resize()
            
        for component in @sub_components
            component.render()
        @append_component()
        for component in @sub_components
            component.show null, true
        animation_complete = =>
            @has_appeared()
            @bind_events()
            callback() if typeof callback is "function"
        if skip_animation
            animation_complete()
        else
            @animate_appearance =>
                animation_complete()

    dismiss: (callback, skip_animation=false) ->
        animation_complete = =>
            @has_disappeared()
            @unbind_events()
            for component in @sub_components
                component.dismiss null, true
            $(window).off "resize.#{@namespace}"
            @remove_component()
            if @data_source
                @data_source.remove()
            callback() if typeof callback is "function"
        if skip_animation
            animation_complete()
        else
            @animate_disapperance =>
                animation_complete()

    create_element: ->
        return crel arguments...

    has_appeared: ->

    has_disappeared: ->

    bind_events: ->
        # Mouse & keyboard bindings, etc.

    unbind_events: ->

    render: ->

    animate_appearance: (callback) ->
        callback()

    animate_disapperance: (callback) ->
        callback()

    append_component: ->
        parent = if @parent_component? then @parent_component.append_to_element else document.body
        parent.appendChild @element if @element

    remove_component: ->
        @element.parentNode?.removeChild @element if @element

    window_resize: ->

    add_sub_component: (component) ->
        @sub_components.push component

    reload_data: ->
        if @data_source
            @dismiss null, true
            @show null, true
