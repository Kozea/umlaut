class Process extends Rect

class IO extends Element
    constructor: ->
        super

        @anchors.E = =>
            x: @x + @width() / 2 - @height() / 4
            y: @y

        @anchors.W = =>
            x: @x - @width() / 2 + @height() / 4
            y: @y

    width: ->
        super() + @height()

    path: ->
        w2 = @txt_width() / 2
        h2 = @height() / 2
        lw2 = @width() / 2

        "M #{-lw2} #{-h2}
         L #{w2} #{-h2}
         L #{lw2} #{h2}
         L #{-w2} #{h2}
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
    constructor: ->
        super
        @margin.x = 0
        @margin.y = 2

class Delay extends Element
    txt_x: ->
        super() - @height() / 4 + @txt_height() / 6

    txt_width: ->
        Math.max(0, super() - @txt_height() / 3)

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


class Database extends Element
    height: ->
        super() + 2.5 * Math.min(@width() / 3,  super() / 2)

    txt_y: ->
        super() + Math.min(@width() / 3, @txt_height() / 2) / 2

    path: ->
        w2 = @width() / 2
        h2 = @txt_height() / 2
        r = Math.min(@width() / 3, h2) * .9
        h2 += r / 2

        "M #{-w2} #{-h2}
         A #{w2} #{r} 0 1 1 #{w2} #{-h2}
         A #{w2} #{r} 0 1 1 #{-w2} #{-h2}
         M #{w2} #{-h2}
         L #{w2} #{h2}
         A #{w2} #{r} 0 1 1 #{-w2} #{h2}
         L #{-w2} #{-h2}"


class HardDisk extends Element
    width: ->
        super() + 2.5 * Math.min(super() / 2, @height() / 3)

    txt_x: ->
        super() - Math.min(@txt_width() / 2, @height() / 3) / 2

    path: ->
        w2 = @txt_width() / 2
        h2 = @height() / 2
        r = Math.min(w2, @height() / 3)
        w2 += r / 2

        "M #{w2} #{h2}
         A #{r} #{h2} 0 1 1 #{w2} #{-h2}
         A #{r} #{h2} 0 1 1 #{w2} #{h2}
         L #{-w2} #{h2}
         A #{r} #{h2} 0 1 1 #{-w2} #{-h2}
         L #{w2} #{-h2}
        "


class ManualInput extends Element
    shift: 1.5

    constructor: ->
        super
        @anchors.N = =>
            x: @x
            y: @y - @txt_height() / 2

    height: ->
        super() * @shift

    txt_y: ->
        super() + (@height() - @txt_height()) / 2

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        th2 = @txt_height() - @height() / 2

        "M #{-w2} #{-th2}
          L #{w2} #{-h2}
          L #{w2} #{h2}
          L #{-w2} #{h2}
          z"

class Preparation extends Element
    width: ->
        super() + @height()

    path: ->
        w2 = @txt_width() / 2
        h2 = @height() / 2

        "M #{-w2 - h2} 0
         L #{-w2} #{-h2}
         L #{w2} #{-h2}
         L #{w2 + h2} 0
         L #{w2} #{h2}
         L #{-w2} #{h2}
         z"

class InternalStorage extends Process
    shift: 10

    width: ->
        super() + @shift

    height: ->
        super() + @shift

    txt_x: ->
        super() + @shift / 2

    txt_y: ->
        super() + @shift / 2

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "#{super()}
         M #{-w2 + @shift} #{-h2}
         L #{-w2 + @shift} #{h2}
         M #{-w2} #{-h2 + @shift}
         L #{w2} #{-h2 + @shift}
        "

class Flow extends Link
    @marker: new Arrow()

class Container extends Group

class FlowChart extends Diagram
    label: 'Flow Chart'

    constructor: ->
       super()
       @types =
           elements: [Process, IO, Terminator, Decision, Delay, SubProcess, Document, Database, HardDisk, ManualInput, Preparation, InternalStorage]
           groups: [Container]
           links: [Flow]

Diagram.diagrams['FlowChart'] = FlowChart
