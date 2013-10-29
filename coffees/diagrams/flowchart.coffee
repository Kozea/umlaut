class Process extends Rect

class IO extends Element
    shift: 5

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2 - @shift} #{-h2}
         L #{w2 - @shift} #{-h2}
         L #{w2 + @shift} #{h2}
         L #{-w2 + @shift} #{h2}
         z"

class Terminator extends Element
    shift: 10

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2 + @shift} #{-h2}
         L #{w2 - @shift} #{-h2}
         Q #{w2} #{-h2} #{w2} #{-h2 + @shift}
         L #{w2} #{h2 - @shift}
         Q #{w2} #{h2} #{w2 - @shift} #{h2}
         L #{-w2 + @shift} #{h2}
         Q #{-w2} #{h2} #{-w2} #{h2 - @shift}
         L #{-w2} #{-h2 + @shift}
         Q #{-w2} #{-h2} #{-w2 + @shift} #{-h2}"

class Decision extends Lozenge

class Delay extends Element
    txt_x: ->
        super() - @height() / 4

    width: ->
        super() + @height() / 2

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2 - h2} #{-h2}
         A #{h2} #{h2} 0 1 1 #{w2 - h2} #{h2}
         L #{-w2} #{h2}
         z"

class SubProcess extends Process
    shift: 10

    width: ->
        super() + 2 * @shift

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "#{super()}
         M #{-w2 + @shift} #{-h2}
         L #{-w2 + @shift} #{h2}
         M #{w2 - @shift} #{-h2}
         L #{w2 - @shift} #{h2}
        "

class Document extends Element
    height: ->
        super() * 1.25

    txt_y: ->
        super() - @height() / 16

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2} #{-h2}
         L #{w2} #{h2}
         Q #{w2 / 2} #{h2 / 2} 0 #{h2}
         T #{-w2} #{h2}
         z"

class Flow extends Link

class FlowChart extends Diagram
    label: 'Flow Chart'

    constructor: ->
        super()
        @types =
            elements: [Process, IO, Terminator, Decision, Delay, SubProcess, Document]
            links: [Flow]

Diagram.diagrams['FlowChart'] = FlowChart
