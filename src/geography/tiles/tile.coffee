###
Tile
The tile is the basic building block of the world. This class
is used to represent information about that space.
###
class engine.geography.tiles.Tile
    @cname = "engine.geography.tiles.Tile"

    @::x   = null # Int
    @::y   = null # Int
    @::z   = null # Int
    @::is_impassable   = false # Something which cannot be passed through by any corporeal creature
    @::is_opaque       = false # Something which cannot be seen through
    @::is_obstacle     = false # Something which a non-flying/non-levitating creature cannot safely pass
