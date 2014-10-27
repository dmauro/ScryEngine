# Module Definition
if typeof define is "function" and define.amd
    define [], ->
        return engine
else if exports?
    # Clone engine into exports
    for key, value of engine
        exports[key] = value
else
    window.engine = engine
