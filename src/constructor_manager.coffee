###
This class helps another class to manage
saving and restoring children. The child's
class must have the correct "cname" property
which is a string that is the same name as
the class name.
###

class engine.ConstructorManager
    constructor: (data) ->
        if data
            @cnames = data
        else
            @cnames = []

    get_save_data_from_object: (obj) ->
        data = obj.get_save_data()
        cid = @cnames.indexOf obj.constructor.cname
        if cid is -1
            @cnames.push obj.constructor.cname
            cid = @cnames.length - 1
        data.c = cid
        return data

    restore_object_from_data: (data) ->
        data = JSON.parse(data) if typeof data is "string"
        cname = @cnames[data.c]
        delete data.c
        cname = cname.split "."
        class_name = engine
        # Pop off the existing "engine"
        cname.shift()
        while cname.length
            class_name = class_name[cname.shift()]
        return new class_name data

    get_save_data: ->
        return @cnames
