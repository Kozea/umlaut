class Process extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2} #{-h2}
         L #{w2} #{h2}
         L #{-w2} #{h2}
         z"

class DataIO extends Element
    @shift: 5

    path: ->
        shift = DataIO.shift

        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2 - shift} #{-h2}
         L #{w2 - shift} #{-h2}
         L #{w2 + shift} #{h2}
         L #{-w2 + shift} #{h2}
         z"

class Terminator extends Element
    @shift: 10

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        shift = Terminator.shift

        "M #{-w2 + shift} #{-h2}
         L #{w2 - shift} #{-h2}
         Q #{w2} #{-h2} #{w2} #{-h2 + shift}
         L #{w2} #{h2 - shift}
         Q #{w2} #{h2} #{w2 - shift} #{h2}
         L #{-w2 + shift} #{h2}
         Q #{-w2} #{h2} #{-w2} #{h2 - shift}
         L #{-w2} #{-h2 + shift}
         Q #{-w2} #{-h2} #{-w2 + shift} #{-h2}"

class Decision extends Element
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

class Delay extends Element
    @shift: 10

    path: ->
        shift = Delay.shift
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2 - shift} #{-h2}
         Q #{w2} #{-h2} #{w2} #{-h2 + shift}
         L #{w2} #{h2 - shift}
         Q #{w2} #{h2} #{w2 - shift} #{h2}
         L #{-w2} #{h2}
         z"

class Arrow extends Link


class FlowChart extends Diagram
    @label: 'Flow Chart'

    constructor: ->
        super()
        @types =
            elements: [Process, DataIO, Terminator, Decision, Delay]
            links: [Arrow]

Diagram.diagrams['FlowChart'] = FlowChart
