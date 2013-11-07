class Process extends Rect

class IO extends Element
    constructor: ->
        super

        @anchors.N = =>
            x: @x - @height() / 4
            y: @y - @height() / 2

        @anchors.S = =>
            x: @x + @height() / 4
            y: @y + @height() / 2

        @anchors.E = =>
            x: @x + @width() / 2 - @height() / 4
            y: @y

        @anchors.W = =>
            x: @x - @width() / 2 + @height() / 4
            y: @y

    txt_width: ->
        super() + @height()

    path: ->
        w2 = (@width() - @height()) / 2
        h2 = @height() / 2
        lw2 = @width() / 2

        "M #{-lw2} #{-h2}
         L #{w2} #{-h2}
         L #{lw2} #{h2}
         L #{-w2} #{h2}
         z"

class Terminator extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        shift = Math.min(w2 / 2, h2 / 2)

        "M #{-w2 + shift} #{-h2}
         L #{w2 - shift} #{-h2}
         Q #{w2} #{-h2} #{w2} #{-h2 + shift}
         L #{w2} #{h2 - shift}
         Q #{w2} #{h2} #{w2 - shift} #{h2}
         L #{-w2 + shift} #{h2}
         Q #{-w2} #{h2} #{-w2} #{h2 - shift}
         L #{-w2} #{-h2 + shift}
         Q #{-w2} #{-h2} #{-w2 + shift} #{-h2}"

class Decision extends Lozenge
    constructor: ->
        super
        @margin.x = 0
        @margin.y = 2

class Delay extends Element
    constructor: ->
        super

        @anchors.N = =>
            x: @x + @txt_x()
            y: @y - @height() / 2

        @anchors.S = =>
            x: @x + @txt_x()
            y: @y + @height() / 2

    txt_x: ->
        super() - @height() / 4 + @txt_height() / 6

    txt_width: ->
        Math.max(0, super() - @txt_height() / 3) + @height() / 2

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2 - h2} #{-h2}
         A #{h2} #{h2} 0 1 1 #{w2 - h2} #{h2}
         L #{-w2} #{h2}
         z"


class SubProcess extends Process
    shift: 1.2

    txt_width: ->
        super() * @shift

    shift_width: ->
        (@width() * (@shift - 1) / @shift)

    path: ->
        w2 = @width() / 2
        lw2 = w2 - @shift_width() / 2
        h2 = @height() / 2

        "#{super()}
         M #{-lw2} #{-h2}
         L #{-lw2} #{h2}
         M #{lw2} #{-h2}
         L #{lw2} #{h2}
        "

class Document extends Element
    txt_height: ->
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
    txt_y: ->
        super() + @radius() / 2

    txt_height: ->
        super() + 20

    radius: ->
        Math.min((@height() - Database.__super__.txt_height.apply(@)) / 4, @width() / 3)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        r = @radius()

        "M #{-w2} #{-h2 + r}
         A #{w2} #{r} 0 1 1 #{w2} #{-h2 + r}
         A #{w2} #{r} 0 1 1 #{-w2} #{-h2 + r}
         M #{w2} #{-h2 + r}
         L #{w2} #{h2 - r}
         A #{w2} #{r} 0 1 1 #{-w2} #{h2 - r}
         L #{-w2} #{-h2 + r}"


class HardDisk extends Element
    txt_x: ->
        super() - @radius() / 2

    txt_width: ->
        super() + 20

    radius: ->
        Math.min((@width() - HardDisk.__super__.txt_width.apply(@)) / 4, @height() / 3)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        r = @radius()

        "M #{w2 - r} #{h2}
         A #{r} #{h2} 0 1 1 #{w2 - r} #{-h2}
         A #{r} #{h2} 0 1 1 #{w2 - r} #{h2}
         L #{-w2 + r} #{h2}
         A #{r} #{h2} 0 1 1 #{-w2 + r} #{-h2}
         L #{w2 - r} #{-h2}
        "


class ManualInput extends Element
    shift: 2

    constructor: ->
        super
        @anchors.N = =>
            x: @x
            y: @y - @shift_height() / 2

        @anchors.W = =>
            x: @x - @width() / 2
            y: @y + @shift_height() / 2

    shift_height: ->
        (@height() * (@shift - 1) / @shift)

    txt_height: ->
        super() * @shift

    txt_y: ->
        super() + @shift_height() / 2

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        th2 = h2 - @shift_height()

        "M #{-w2} #{-th2}
          L #{w2} #{-h2}
          L #{w2} #{h2}
          L #{-w2} #{h2}
          z"

class Preparation extends Element
    shift: 1.25

    txt_width: ->
        super() * @shift

    shift_width: ->
        (@width() * (@shift - 1) / @shift)

    path: ->
        w2 = @width() / 2
        lw2 = w2 - @shift_width() / 2
        h2 = @height() / 2

        "M #{-w2} 0
         L #{-lw2} #{-h2}
         L #{lw2} #{-h2}
         L #{w2} 0
         L #{lw2} #{h2}
         L #{-lw2} #{h2}
         z"

class InternalStorage extends Process
    hshift: 1.5
    wshift: 1.1

    txt_x: ->
        super() + @shift_width() / 2

    txt_y: ->
        super() + @shift_height() / 2

    txt_width: ->
        super() * @wshift

    txt_height: ->
        super() * @hshift

    shift_width: ->
        (@width() * (@wshift - 1) / @wshift)

    shift_height: ->
        (@height() * (@hshift - 1) / @hshift)

    path: ->
        w2 = @width() / 2
        lw2 = w2 - @shift_width()
        h2 = @height() / 2
        lh2 = h2 - @shift_height()

        "#{super()}
         M #{-lw2} #{-h2}
         L #{-lw2} #{h2}
         M #{-w2} #{-lh2}
         L #{w2} #{-lh2}
        "

class Flow extends Link
    @marker: new BlackArrow()

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
