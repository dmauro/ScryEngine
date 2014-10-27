class engine.geography.tiles.Base
    @cname = "engine.geography.tiles.Base"

    @::x   = null # Int
    @::y   = null # Int
    @::z   = null # Int
    @::is_impassable   = false # Something which cannot be passed through by any corporeal creature
    @::is_opaque       = false # Something which cannot be seen through
    @::is_obstacle     = false # Something which a non-flying/non-levitating creature cannot safely pass

class engine.geography.tiles.Floor extends engine.geography.tiles.Base
    @cname = "engine.geography.tiles.Floor"

class engine.geography.tiles.Wall extends engine.geography.tiles.Base
    @cname = "engine.geography.tiles.Wall"

    @::is_impassable   = true
    @::is_obstacle     = true
    @::is_opaque       = true

class engine.geography.tiles.Obstacle extends engine.geography.tiles.Base
    @cname = "engine.geography.tiles.Obstacle"

    @::is_obstacle     = true

class engine.geography.tiles.Window extends engine.geography.tiles.Base
    @cname = "engine.geography.tiles.Window"

    @::is_impassable   = true
    @::is_obstacle     = true
