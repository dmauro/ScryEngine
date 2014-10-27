class engine.ui.components.Menu extends engine.ui.components.Base
    styles: ["menu"]

    render: ->
        ul = @create_element 'ul'
        for i in [0...@data_source.length]
            ul.appendChild @create_element 'li',
                @create_element 'span', "#{@data_source.get_option_text_at_index(i)}"
        return ul

    bind_events: ->
        self = @
        $("##{@namespace} li").on "click", ->
            callback = self.data_source.get_option_selection_callback_at_index $(this).index()
            callback() if callback?

    unbind_events: ->
        $("#{@namespace} li").off "click"

    animate_appearance: (callback) ->
        @element.setAttribute "style", "opacity:0;top:-500px;position:relative"
        $(@element).animate {opacity : 1, top:0}, 500, callback

    animate_disapperance: (callback) ->
        $(@element).animate {opacity : 0}, 200, callback
