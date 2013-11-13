class Electric extends Element
    @resizeable: false
    @rotationable: true

    anchor_list: ->
        ['W', 'E']

    base_height: ->
        20

    base_width: ->
        20

    txt_y: ->
        @height() / 2 + @margin.y

    txt_height: ->
        @base_height()

    txt_width: ->
        @base_width()

    direction: (x, y) ->
        if @_rotation < 45 or 135 < @_rotation < 225 or @_rotation > 315
            if x > @x
                return 'E'
            return 'W'
        if y > @y
            return 'S'
        return 'N'

class Node extends Electric
    base_width: ->
        super() / 4

    base_height: ->
        super() / 4

    constructor: ->
        super
        @margin.x = 0
        @margin.y = 0
        @text = ''

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "M 0 #{-h2}
         A #{w2} #{h2} 0 0 1 0 #{h2}
         A #{w2} #{h2} 0 0 1 0 #{-h2}
        "

class Resistor extends Electric
    @fill: 'none'

    base_width: ->
        super() * 3

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        path = "M #{-w2} 0"
        for w in [-3..2]
            path = "#{path} L #{w2 * w / 3 + w2 / 6} #{h2 * if w % 2 then -1 else 1}"
        "#{path} L #{w2} 0"


class Diode extends Electric
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "M #{-w2} #{-h2}
         L #{w2} 0
         L #{w2} #{-h2}
         L #{w2} #{h2}
         L #{w2} 0
         L #{-w2} #{h2}
        z"

class Battery extends Electric
    @fill: 'fg'

    base_width: ->
        super() / 3

    base_height: ->
        super() * 2

    path: ->
        w2 = @width() / 2
        w4 = @width() / 4
        h2 = @height() / 2
        h4 = h2 / 2
        "M #{-w2} #{-h4}
         L #{-w4} #{-h4}
         L #{-w4} #{h4}
         L #{-w2} #{h4}
         z
         M #{w2} #{-h2}
         L #{w2} #{h2}
        "

class Wire extends Link

    path: ->
        c1 = @source.pos()
        c2 = @target.pos()
        if undefined in [c1.x, c1.y, c2.x, c2.y]
            return 'M 0 0'

        @d1 = @source_anchor or @source.direction(c2.x, c2.y)
        @a1 = @source.rotate(@source.anchors[@d1]())

        @d2 = @target_anchor or @target.direction(c1.x, c1.y)
        @a2 = @target.rotate(@target.anchors[@d2]())

        path = "M #{@a1.x} #{@a1.y} L"

        if c2.x > c1.x or c2.y > c1.y and not (c2.x > c1.x and c2.y > c1.y)
            path = "#{path} #{@a1.x} #{@a2.y} L"
        else
            path = "#{path} #{@a2.x} #{@a1.y} L"

        "#{path} #{@a2.x} #{@a2.y}"

class ElectricDiagram extends Diagram
    label: 'Electric Diagram'

    constructor: ->
       super
       @types =
           elements: [Diode, Resistor, Node, Battery]
           groups: []
           links: [Wire]

Diagram.diagrams['ElectricDiagram'] = ElectricDiagram
