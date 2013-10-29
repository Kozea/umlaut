class Element
    constructor: (@x, @y, @text, @fixed=true) ->
        @margin = x: 10, y: 5

    pos: ->
        x: @x
        y: @y

    set_txt_bbox: (bbox) ->
        @_txt_bbox = bbox

    txt_width: ->
        @_txt_bbox.width

    txt_height: ->
        @_txt_bbox.height

    txt_x: ->
        0

    txt_y: ->
        - @txt_height() / 2

    width: ->
        @txt_width() + 2 * @margin.x

    height: ->
        @txt_height() + 2 * @margin.y

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
