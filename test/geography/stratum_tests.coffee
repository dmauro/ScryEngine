should = require 'should'
assert = require 'assert'
engine = require '../../bin/engine'

describe "Stratum", ->

    constructor_manager = null
    zone_manager = null
    stratum = null
    z_level = 0
    seed = 1

    helpers =
        restore_stratum: ->
            data = stratum.get_save_data()
            stratum = new engine.geography.Stratum data, constructor_manager
            helpers.setup_handlers()

        setup_handlers: ->
            stratum.get_zone_info_handler = (zone_x, zone_y) ->
                return zone_manager.get_zone_info_at zone_x, zone_y, z_level
            stratum.get_seed_for_coordinate_handler = (zone_x, zone_y) ->
                return seed

    beforeEach ->
        constructor_manager = new engine.ConstructorManager()
        zone_manager = new engine.geography.ZoneManager()
        stratum = new engine.geography.Stratum null, constructor_manager
        stratum.zone_size = 1
        helpers.setup_handlers()

    it "creates a the zone at the specified location", ->
        zone = stratum._create_zone_at 1, 2
        stratum.zones.get_value_at(1, 2).should.equal zone
        assert.ok zone instanceof engine.geography.zones.Zone

    it "always returns a zone at the queried location", ->
        zone = stratum.get_zone_at_zone_position 5, 10
        assert.ok zone instanceof engine.geography.zones.Zone

    it "gets the correct zone coordinates from global coordinates", ->
        stratum.zone_size = 10
        coords = stratum._get_zone_coordinate_from_global_coordinate 25, 25
        coords.x.should.equal 2
        coords.y.should.equal 2

    it "gets the coorect local coords from global coords", ->
        stratum.zone_size = 10
        coords = stratum._get_local_coordinate_from_global_coordinate 25, 25
        coords.x.should.equal 5
        coords.y.should.equal 5

    it "creates the correct neighbor zone", ->
        stratum.create_neighbor_zones_at 0, 0
        should.exist stratum.zones.get_value_at -1, -1
        should.exist stratum.zones.get_value_at 0, -1
        should.exist stratum.zones.get_value_at -1, 0
        should.exist stratum.zones.get_value_at 1, 1
        should.exist stratum.zones.get_value_at 0, 1
        should.exist stratum.zones.get_value_at 0, 0

    describe "restoration", ->
        it "restores zones that have been created", ->
            stratum._create_zone_at 1, 2
            helpers.restore_stratum()
            should.exist stratum.zones.get_value_at 1, 2

        it "can continue generating new zones", ->
            helpers.restore_stratum()
            stratum._create_zone_at 1, 2
            should.exist stratum.zones.get_value_at 1, 2

        it "still gets the correct zone coordinates from global coordinates", ->
            helpers.restore_stratum()
            stratum.zone_size = 10
            coords = stratum._get_zone_coordinate_from_global_coordinate 25, 25
            coords.x.should.equal 2
            coords.y.should.equal 2

        it "still gets the coorect local coords from global coords", ->
            helpers.restore_stratum()
            stratum.zone_size = 10
            coords = stratum._get_local_coordinate_from_global_coordinate 25, 25
            coords.x.should.equal 5
            coords.y.should.equal 5
