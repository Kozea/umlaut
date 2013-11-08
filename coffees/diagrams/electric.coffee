class Electric extends Element
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
        d = super(x, y)
        if @_rotation % 180 == 0
            if d == 'N'
                d = 'W'
            if d == 'S'
                d = 'E'

        if @_rotation % 180 == 90
            if d == 'W'
                d = 'N'
            if d == 'E'
                d = 'S'

        d

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
    base_width: ->
        super() / 2

    base_height: ->
        super() * 2

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        h4 = h2 / 2
        "M #{-w2} #{-h4}
         L 0 #{-h4}
         L 0 #{h4}
         L #{-w2} #{h4}
         z
         M #{w2} #{-h2}
         L #{w2} #{h2}
        "


class Wire extends Link

class ElectricDiagram extends Diagram
    label: 'Electric Diagram'

    constructor: ->
       super()
       @types =
           elements: [Diode, Resistor, Node, Battery]
           groups: []
           links: [Wire]

Diagram.diagrams['ElectricDiagram'] = ElectricDiagram
