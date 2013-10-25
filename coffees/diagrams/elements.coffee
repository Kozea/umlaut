class Element
    constructor: (@x, @y, @text, @fixed=true) ->
        @margin = x: 10, y: 5

    pos: ->
        x: @x
        y: @y

    width: ->
        @_txt_bbox.width + 2 * @margin.x

    height: ->
        @_txt_bbox.height + 2 * @margin.y

    direction: (x, y) ->
        delta = @height() / @width()

        if @x <= x and @y <= y
            if y > delta * (x - @x) + @y
                return 'S'
            else
                return 'E'
        if @x >= x and @y <= y
            if y > delta * (@x - x) + @y
                return 'S'
            else
                return 'O'
        if @x <= x and @y >= y
            if y > delta * (@x - x) + @y
                return 'E'
            else
                return 'N'
        if @x >= x and @y >= y
            if y > delta * (x - @x) + @y
                return 'O'
            else
                return 'N'

    anchor: (direction) ->
        switch direction
            when 'N'
                x: @x
                y: @y - @height() / 2
            when 'S'
                x: @x
                y: @y + @height() / 2
            when 'E'
                x: @x + @width() / 2
                y: @y
            when 'O'
                x: @x - @width() / 2
                y: @y

    in: (rect) ->
        rect.x < @x < rect.x + rect.width and rect.y < @y < rect.y + rect.height

    objectify: ->
        name: @constructor.name
        x: @x
        y: @y
        text: @text
        fixed: @fixed

class Mouse extends Element
    width: -> 1
    height: -> 1
    weight: 1

E = {}
L = {}

class E.Process extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2} #{-h2}
         L #{w2} #{h2}
         L #{-w2} #{h2}
         z"

class E.DataIO extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        shift = 5

        "M #{-w2 - shift} #{-h2}
         L #{w2 - shift} #{-h2}
         L #{w2 + shift} #{h2}
         L #{-w2 + shift} #{h2}
         z"

class E.Terminator extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        shift = 10

        "M #{-w2 + shift} #{-h2}
         L #{w2 - shift} #{-h2}
         Q #{w2} #{-h2} #{w2} #{-h2 + shift}
         L #{w2} #{h2 - shift}
         Q #{w2} #{h2} #{w2 - shift} #{h2}
         L #{-w2 + shift} #{h2}
         Q #{-w2} #{h2} #{-w2} #{h2 - shift}
         L #{-w2} #{-h2 + shift}
         Q #{-w2} #{-h2} #{-w2 + shift} #{-h2}"

class E.Decision extends Element
    constructor: ->
        super
        @margin.y = 0

    width: ->
        ow = super()
        ow + Math.sqrt(ow * @_txt_bbox.height + 2 * @margin.y)

    height: ->
        oh = super()
        oh + Math.sqrt(oh * @_txt_bbox.width + 2 * @margin.x)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "M #{-w2} 0
         L 0 #{-h2}
         L #{w2} 0
         L 0 #{h2}
         z"

class E.Delay extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        shift = 10

        "M #{-w2} #{-h2}
         L #{w2 - shift} #{-h2}
         Q #{w2} #{-h2} #{w2} #{-h2 + shift}
         L #{w2} #{h2 - shift}
         Q #{w2} #{h2} #{w2 - shift} #{h2}
         L #{-w2} #{h2}
         z"
