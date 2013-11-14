class Electric extends Element
    @resizeable: false
    @rotationable: true

    anchor_list: ->
        ['W', 'E']

    base_height: ->
        20

    _base_width: ->
        20

    base_width: ->
        @_base_width() + 2 * @wire_margin()

    wire_margin: ->
        10

    txt_y: ->
        @height() / 2 + @margin.y

    txt_height: ->
        @base_height()

    txt_width: ->
        @base_width()


class Node extends Electric

    constructor: ->
        super
        @margin.x = 0
        @margin.y = 0
        @text = ''

    base_width: ->
        @_base_width() / 4

    base_height: ->
        super() / 4

    anchor_list: ->
        ['N', 'S', 'W', 'E']

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "M 0 #{-h2}
         A #{w2} #{h2} 0 0 1 0 #{h2}
         A #{w2} #{h2} 0 0 1 0 #{-h2}
        "

class Resistor extends Electric
    @fill: 'none'

    _base_width: ->
        super() * 3

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        lw2 = w2 - @wire_margin()
        path = "M #{-w2} 0
                L #{-lw2} 0"
        for w in [-3..2]
            path = "#{path} L #{lw2 * w / 3 + lw2 / 6} #{h2 * if w % 2 then -1 else 1}"
        "#{path}
         L #{lw2} 0
         L #{w2} 0"


class Diode extends Electric
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        lw2 = w2 - @wire_margin()
        "M #{-w2} 0
         L #{-lw2} 0
         M #{-lw2} #{-h2}
         L #{lw2} 0
         L #{lw2} #{-h2}
         L #{lw2} #{h2}
         L #{lw2} 0
         L #{-lw2} #{h2}
        z
         M #{lw2} 0
         L #{w2} 0
        "

class Battery extends Electric
    @fill: 'fg'

    _base_width: ->
        super() / 3

    base_height: ->
        super() * 2

    path: ->
        w2 = @width() / 2
        lw2 = w2 - @wire_margin()
        lw4 = lw2 / 2
        h2 = @height() / 2
        h4 = h2 / 2

        "M #{-w2} 0
         L #{-lw2} 0
         M #{-lw2} #{-h4}
         L #{-lw4} #{-h4}
         L #{-lw4} #{h4}
         L #{-lw2} #{h4}
         z
         M #{lw2} #{-h2}
         L #{lw2} #{h2}
         M #{lw2} 0
         L #{w2} 0
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

        if angle_to_cardinal(@source._rotation) in ['E', 'W']
            path = "#{path} #{@a2.x} #{@a1.y} L"
        else
            path = "#{path} #{@a1.x} #{@a2.y} L"

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
