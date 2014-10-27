###
This class is in charge of managing which
zones go where and how they connect.
###

class engine.geography.ZoneManager
    constructor: (data) ->
        if data
            @_restore data

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"
        for own property, value of data
            if property is "random"
                value = new engine.random.Alea value
            @[property] = value

    get_save_data: ->
        save_data = {}
        for own property, value of @
            if property is "random"
                value = value.get_save_data()
            save_data[property] = value
        JSON.stringify save_data
        return save_data

    #######################
    # Subclassing Methods #
    #######################

    init: ->
        ###
        Public method for overriding
        You can render a world layout here if you'd like.
        Any properties set on the ZoneManager will
        persist

        ZoneManager is supplied a 'random' instance
        variable by the World, which you can use here.
        ###
        return

    get_zone_info_at: (x, y, z) ->
        return {
            constructor : engine.geography.zones.Base
            entrances   : [] # An array of ZonePoints
            pathways    : [] # An array of ZonePaths
        }

###
A class for describing a pathway
that a zone should respect as being
passable by the player.

A path can have any number of entrances
and any number of exits. They should all
be reachable from one-another.
###

class engine.geography.ZonePath
    constuctor: (@entrances, @exits) ->

###
These are the points used by entrances
and exits. The x and y coordinates are
local to the zone in question.
###

class engine.geography.ZonePoint
    constructor: (@x, @y, @exit_directions) ->
        ###
        Exit directions is an array of:
        north
        south
        east
        west
        up
        down
        ###
