class Rect extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2} #{-h2}
         L #{w2} #{h2}
         L #{-w2} #{h2}
         z"

class Ellipsis extends Element
    txt_width: ->
        2 * super() / Math.sqrt(2)

    txt_height: ->
        2 * super() / Math.sqrt(2)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} 0
         A #{w2} #{h2} 0 1 1 #{w2} 0
         A #{w2} #{h2} 0 1 1 #{-w2} 0
        "

class Note extends Element
    shift: 15

    txt_width: ->
        super() + @shift

    txt_x: ->
        super() - @shift / 2

    txt_y: ->
        super()

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2 - @shift} #{-h2}
         L #{w2} #{-h2 + @shift}
         L #{w2} #{h2}
         L #{-w2} #{h2}
         L #{-w2} #{-h2 + @shift}
         z
         M #{w2} #{-h2 + @shift}
         L #{w2 - @shift} #{-h2 + @shift}
         L #{w2 - @shift} #{-h2}
        "

class Lozenge extends Element
    txt_width: ->
        ow = super()
        ow + Math.sqrt(ow * @super('txt_height', Lozenge))

    txt_height: ->
        oh = super()
        oh + Math.sqrt(oh * @super('txt_width', Lozenge))

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "M #{-w2} 0
         L 0 #{-h2}
         L #{w2} 0
         L 0 #{h2}
         z"

class WhiteArrow extends BlackArrow

class Diamond extends Marker
    path: ->
        'M 0 5 L 10 0 L 20 5 L 10 10 z'

class WhiteDiamond extends Diamond

class Association extends Link
    @marker: new BlackArrow()

class Inheritance extends Link
    @marker: new WhiteArrow()

class Composition extends Link
    @marker: new Diamond()

class Comment extends Link
    @marker: new Arrow()
    @type: 'dashed'

class Aggregation extends Link
    @marker: new WhiteDiamond()


uml_links = [Association, Inheritance, Aggregation, Composition, Comment]
uml_elements = [Note]
