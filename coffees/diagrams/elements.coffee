class Element extends Base
    @handle_size: 10
    @resizeable: true
    @rotationable: false
    @fill: 'bg'
    @stroke: 'fg'

    constructor: (@x, @y, @text, @fixed=true) ->
        super
        @margin = x: 10, y: 5
        @_width = null
        @_height = null
        @_rotation = 0
        @anchors =
            N: =>
                x: @x
                y: @y - @height() / 2
            S: =>
                x: @x
                y: @y + @height() / 2
            E: =>
                x: @x + @width() / 2
                y: @y
            W: =>
                x: @x - @width() / 2
                y: @y

        @handles =
            NE: =>
                x: @width() / 2
                y: - @height() / 2
            NW: =>
                x: - @width() / 2
                y: - @height() / 2
            SW: =>
                x: - @width() / 2
                y: @height() / 2
            SE: =>
                x: @width() / 2
                y: @height() / 2
            O: =>
                x: 0
                y: - @height() / 2

    rotate: (pos) ->
        rad = Math.PI * @_rotation / 180
        x = pos.x - @x
        y = pos.y - @y
        x: x * Math.cos(rad) - y * Math.sin(rad) + @x
        y: x * Math.sin(rad) + y * Math.cos(rad) + @y

    anchor_list: ->
        ['N', 'S', 'W', 'E']

    handle_list: ->
        l = []
        if @cls.resizeable
            l = l.concat(['NW', 'NE', 'SW', 'SE'])
        if @cls.rotationable
            l.push('O')
        l

    pos: ->
        @rotate(
            x: @x
            y: @y)

    set_txt_bbox: (bbox) ->
        @_txt_bbox = bbox

    txt_width: ->
        @_txt_bbox.width + 2 * @margin.x

    txt_height: ->
        @_txt_bbox.height + 2 * @margin.y

    txt_x: ->
        0

    txt_y: ->
        - @_txt_bbox.height / 2

    width: (w=null) ->
        if w != null
            @_width = w
        Math.max(@_width or 0, @txt_width())

    height: (h=null) ->
        if h != null
            @_height = h
        Math.max(@_height or 0, @txt_height())

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
                return 'W'
        if @x <= x and @y >= y
            if y > delta * (@x - x) + @y
                return 'E'
            else
                return 'N'
        if @x >= x and @y >= y
            if y > delta * (x - @x) + @y
                return 'W'
            else
                return 'N'

    in: (rect) ->
        rect.x < @x < rect.x + rect.width and rect.y < @y < rect.y + rect.height

    contains: ->
        false

    objectify: ->
        name: @constructor.name
        x: @x
        y: @y
        width: @_width
        height: @_height
        rotation: @_rotation
        text: @text
        fixed: @fixed


class Mouse extends Element
    width: -> 1
    height: -> 1
    weight: 1
