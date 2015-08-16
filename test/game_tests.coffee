should = require 'should'
assert = require 'assert'
engine = require '../bin/engine'

helpers =
    create_game: ->
        game = new engine.Game()
        protagonist = new engine.things.Sentient()
        game.set_protagonist protagonist
        return game

describe "Game", ->
    describe "Savestates", ->
        it "should be able to save and restore a game", ->
            game = helpers.create_game()
            thing = new engine.things.Thing()
            brain = new engine.things.Brain()
            thing.maxhp = 10
            game.registry.register_thing thing
            game.registry.register_thing brain
            game_save = JSON.stringify game._get_save_data()

            # Transfer storage to new game registry
            class Game extends engine.Game
                _create_registry: (data) ->
                    Registry = @constructor_for_name "registry"
                    return new Registry data, game.registry.cache

            new_game = new Game game_save
            new_thing = new_game.registry.get_thing thing.id
            new_thing.maxhp.should.equal 10
            new_game.timekeeper.things[0].time.should.be.a.Number
        it "should be able to restore from a quick-save", ->
            # Make sure both games use same storage object
            cache = new engine.Storage()
            class Game extends engine.Game
                _create_registry: (data) ->
                    return new engine.things.Registry data, cache

            game = new Game()
            protagonist = new engine.things.Sentient()
            game.set_protagonist protagonist

            thing_cached = new engine.things.Thing()
            thing_cached.maxhp = 10
            game.registry.register_thing thing_cached
            game.registry.cache_thing thing_cached.id
            thing_uncached = new engine.things.Thing()
            thing_uncached.maxhp = 8
            game.registry.register_thing thing_uncached
            quick_save = JSON.stringify game._get_quicksave_data()

            new_game = new Game quick_save
            cached = new_game.registry.get_thing thing_cached.id
            cached.maxhp.should.equal 10
            uncached = new_game.registry.get_thing thing_uncached.id
            uncached.maxhp.should.equal 8

    describe "Protagonist", ->
        it "can have a protagonist", ->
            game = helpers.create_game()
            thing = new engine.things.Sentient()
            game.set_protagonist thing
            game.world.get_protagonist().get_host().x.should.equal 0
            game.world.get_protagonist().get_host().y.should.equal 0
