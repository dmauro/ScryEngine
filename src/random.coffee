class engine.random.Mash
    # Version 0.9
    constructor: ->
        @n = 0xefc8249d

    mash: (data) ->
        data = data.toString()
        for i in [0..data.length - 1]
            @n += data.charCodeAt i
            h = 0.02519603282416938 * @n
            @n = h >>> 0
            h -= @n
            h *= @n
            @n = h >>> 0
            h -= @n
            @n += h* 0x100000000 # 2^32
        return (@n >>> 0) * 2.3283064365386963e-10 # 2^-32

class engine.random.Alea
    # Alea 0.9
    constructor: (data, seeds) ->
        if data?
            @_restore data
        else
            @_init seeds

    _init: (seeds) ->
        @seeds = seeds or [+new Date()]
        @c = 1
        mash = new engine.random.Mash()
        @s0 = mash.mash ' '
        @s1 = mash.mash ' '
        @s2 = mash.mash ' '
        for seed in @seeds
            @s0 -= mash.mash seed
            @s0 += 1 if @s0 < 0
            @s1 -= mash.mash seed
            @s1 += 1 if @s1 < 0
            @s2 -= mash.mash seed
            @s2 += 1 if @s2 < 0

    _restore: (data) ->
        data = JSON.parse data if typeof data is "string"
        @seeds = data.seeds
        @c = data.c
        @s0 = data.s0
        @s1 = data.s1
        @s2 = data.s2

    random: ->
        t = 2091639 * @s0 + @c * 2.3283064365386963e-10 # 2^-32
        @s0 = @s1;
        @s1 = @s2;
        return @s2 = t - (@c = t | 0);

    range: (min, max) ->
        return Math.round @random() * (max - min) + min

    choice: (array) ->
        return array[@range 0, array.length - 1]

    uint32: ->
        return @random() * 0x100000000 # 2^32

    fract53: ->
        return @random() + (@random() * 0x200000 | 0) * 1.1102230246251565e-16 # 2^-53

    get_save_data: ->
        return JSON.stringify @
