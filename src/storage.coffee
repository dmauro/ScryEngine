##############################
# Persistent Storage Manager #
##############################

class engine.Storage
    constructor: ->
        @use_local_storage = localStorage?
        # Mem storage just used for mocha testing
        @use_memory_storage = not window?
        @data = {}

    set_item: (key, data) ->
        if @use_local_storage
            localStorage.setItem key, data
        if @use_memory_storage
            @data[key] = data

    get_item: (key) ->
        if @use_local_storage
            data = localStorage.getItem key
        if @use_memory_storage
            data = @data[key]
        return data

    remove_item: (key) ->
        if @use_local_storage
            localStorage.removeItem key
        if @use_memory_storage
            @data[key] = null

    get_remaining_space = ->
        if @use_local_storage
            # Temp estimate
            return 1024 * 1024 * 5 - unescape(encodeURIComponent JSON.stringify localStorage).length
        else
            return 0
