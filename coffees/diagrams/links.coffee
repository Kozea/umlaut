class Marker extends Base
    constructor: ->
        super
        @id = @constructor.name

class Void extends Marker
    path: ->
        'M 0 0'

class Arrow extends Marker
    path: ->
        'M 10 0 L 20 5 L 10 10'

class BlackArrow extends Arrow
    path: ->
        "#{super()} z"

class Link extends Base
    @marker: new Void()
    @type: 'full'

    text_margin: 10

    constructor: (@source, @target, text) ->
        super
        @a1 = @a2 = 0
        @text =
            source: text?.source or ''
            target: text?.target or ''

    objectify: ->
        name: @constructor.name
        source: diagram.nodes().indexOf(@source)
        target: diagram.nodes().indexOf(@target)
        source_anchor: @source_anchor
        target_anchor: @target_anchor
        text: @text

    nearest: (pos) ->
        if dist(pos, @a1) < dist(pos, @a2) then @source else @target

    path: ->
        c1 = @source.pos()
        c2 = @target.pos()
        if null in [c1, c2] or undefined in [c1.x, c1.y, c2.x, c2.y]
            return 'M 0 0'

        d1 = +if @source_anchor? then @source_anchor else @source.direction(c2.x, c2.y)
        @a1 = @source.rotate(@source.anchors[d1]())

        d2 = +if @target_anchor? then @target_anchor else @target.direction(@a1.x, @a1.y)
        @a2 = @target.rotate(@target.anchors[d2]())

        @o1 = d1 + @source._rotation
        @o2 = d2 + @target._rotation

        path = "M #{@a1.x} #{@a1.y}"

        horizontal_1 = Math.abs(d1 % pi) < pi / 4
        horizontal_2 = Math.abs(d2 % pi) < pi / 4

        if diagram.linkstyle == 'demicurve'
            path = "#{path} C"
            m =
                x: .5 * (@a1.x + @a2.x)
                y: .5 * (@a1.y + @a2.y)

            if horizontal_1
                path = "#{path} #{m.x} #{@a1.y}"
            else
                path = "#{path} #{@a1.x} #{m.y}"

            if horizontal_2
                path = "#{path} #{m.x} #{@a2.y}"
            else
                path = "#{path} #{@a2.x} #{m.y}"
        else if diagram.linkstyle == 'diagonal'
            path = "#{path} L"
        else if diagram.linkstyle == 'rectangular'
            path = "#{path} L"
            if not horizontal_1 and horizontal_2
                path = "#{path} #{@a1.x} #{@a2.y} L"
            else if horizontal_1 and not horizontal_2
                path = "#{path} #{@a2.x} #{@a1.y} L"
            else if horizontal_1 and horizontal_2
                mid = @a1.x + .5 * (@a2.x - @a1.x)
                path = "#{path} #{mid} #{@a1.y} L #{mid} #{@a2.y} L"
            else if not horizontal_1 and not horizontal_2
                mid = @a1.y + .5 * (@a2.y - @a1.y)
                path = "#{path} #{@a1.x} #{mid} L #{@a2.x} #{mid} L"
        else if diagram.linkstyle == 'curve'
            path = "#{path} C"
            d = dist(@a1, @a2) / 2

            dx =  Math.cos(@o1) * d
            dy =  Math.sin(@o1) * d
            path = "#{path} #{@a1.x + dx} #{@a1.y + dy}"

            dx =  Math.cos(@o2) * d
            dy =  Math.sin(@o2) * d
            path = "#{path} #{@a2.x + dx} #{@a2.y + dy}"

        "#{path} #{@a2.x} #{@a2.y}"
