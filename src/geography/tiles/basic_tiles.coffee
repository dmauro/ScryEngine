# Basic Tile subclasses

class engine.geography.tiles.Floor extends engine.geography.tiles.Tile
    @cname = "engine.geography.tiles.Floor"

class engine.geography.tiles.Wall extends engine.geography.tiles.Tile
    @cname = "engine.geography.tiles.Wall"

    @::is_impassable   = true
    @::is_obstacle     = true
    @::is_opaque       = true

class engine.geography.tiles.Obstacle extends engine.geography.tiles.Tile
    @cname = "engine.geography.tiles.Obstacle"

    @::is_obstacle     = true

class engine.geography.tiles.Window extends engine.geography.tiles.Tile
    @cname = "engine.geography.tiles.Window"

    @::is_impassable   = true
    @::is_obstacle     = true
