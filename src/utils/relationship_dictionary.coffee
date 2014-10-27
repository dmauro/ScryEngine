###
A dictionary that requires two keys for
each entry. The key order is inconsequential.
###

class engine.utils.RelationshipDictionary
    constructor: (data) ->
        for own key_1, key_2s of data
            @[key_1] = {}
            for own key_2, value of key_2s
                @[key_1][key_2] = value

    get_value_for_keys: (key_1, key_2) ->
        value = @[key_1]?[key_2]
        value = @[key_2]?[key_1] unless value?
        return value

    set_value_for_keys: (key_1, key_2, value) ->
        if @[key_1]?[key_2]?
            @[key_1][key_2] = value
        else if @[key_2]?@[key_1]?
            @[key_2][key_1] = value
        else if @[key_1]?
            @[key_1][key_2] = value
        else if @[key_2]?
            @[key_2][key_1] = value
        else
            @[key_1] = {}
            @[key_1][key_2] = value

    get_save_data: ->
        save_data = {}
        for own key_1, key_2s of @
            save_data[key_1] = {}
            for own key_2, value of key_2s
                save_data[key_1][key_2] = value
        return save_data
