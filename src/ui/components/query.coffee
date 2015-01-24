###
Query
This component collects input from the user.
###
class engine.ui.components.Query extends engine.ui.components.Component
    styles: ["query"]

    render: ->
        div = @create_element 'div',
            if @data_source.query_title then @create_element 'h1', @data_source.query_title else null
            ul = @create_element 'ul'
        for i in [0...@data_source.length]
            label = @data_source.get_query_label_at_index(i)
            li = @create_element 'li'
            if label
                li.appendChild @create_element 'label', label
            li.appendChild @create_element 'input', {type : "text", name : "#{@data_source.get_query_name_at_index(i)}"}
            ul.appendChild li
        div.appendChild @create_element 'button', {type : "submit"}, @data_source.submit_label or "Submit"
        return div

    bind_events: ->
        $("##{@namespace} button").on "click", =>
            @submit_query()

    unbind_events: ->
        $("##{@namespace} button").off "click"

    submit_query: ->
        if @on_submit_callback?
            response = {}
            $("##{@namespace} input").each (i, input) =>
                response[input.getAttribute("name")] = input.value
            @on_submit_callback response
