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
    width: ->
        2 * super() / Math.sqrt(2)

    height: ->
        2 * super() / Math.sqrt(2)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} 0
         A #{w2} #{h2} 0 1 1 #{w2} 0
         A #{w2} #{h2} 0 1 1 #{-w2} 0
        "

class Lozenge extends Element
    width: ->
        ow = super()
        ow + Math.sqrt(ow * @txt_height() + 2 * @margin.y)

    height: ->
        oh = super()
        oh + Math.sqrt(oh * @txt_width() + 2 * @margin.x)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "M #{-w2} 0
         L 0 #{-h2}
         L #{w2} 0
         L 0 #{h2}
         z"
