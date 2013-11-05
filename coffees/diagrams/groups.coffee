class Group extends Element
    height: ->
        Math.max(@_height, super())

    width: ->
        Math.max(@_width, super())

    contains: (elt) ->
        w2 = @width() / 2
        h2 = @height() / 2

        @x - w2 < elt.x < @x + w2 and @y - h2 < elt.y < @y + h2

    objectify: ->
        name: @constructor.name
        x: @x
        y: @y
        width: @width()
        height: @height()
        text: @text
        fixed: @fixed

    txt_y: ->
        - @height() / 2 + @margin.y

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        h2l = -h2 + @txt_height() + @margin.y
        "M #{-w2} #{-h2}
         L #{w2} #{-h2}
         L #{w2} #{h2l}
         L #{-w2} #{h2l}
         z
         M #{w2} #{h2l}
         L #{w2} #{h2}
         L #{-w2} #{h2}
         L #{-w2} #{h2l}
        "
