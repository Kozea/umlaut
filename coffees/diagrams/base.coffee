class Base
    constructor: ->
        @cls = @constructor

    super: (fun, cls=null, args=[]) ->
        (cls or @cls).__super__[fun].apply(@, args)
