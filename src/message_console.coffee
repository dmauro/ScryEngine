###
Responsible for tracking traditional console
style messages and displaying them to the user.
###

class engine.MessageConsole
    constructor: (data) ->
        if data?
            @_restore data
        else
            @_init()

    _init: ->
        @message_history_length = 0
        @messages = []

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"
        @message_history_length = data.message_history_length
        @messages = data.messages

    show_message: (message, args...) ->
        while args.length
            variable = args.shift()
            index = message.indexOf "%@"
            message = message.slice(0, index) + variable + message.slice(index + 2)
        @_add_message message

    _add_message: (message) ->
        @messages.push message
        if @message_history_length > 0
            while @messages.length > @message_history_length
                @messages.unshift()

    get_save_data: (is_quicksave=false) ->
        save_data =
            message_history_length  : @message_history_length
            messages                : @messages
        return save_data
