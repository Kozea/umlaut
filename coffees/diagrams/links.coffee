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
        if undefined in [c1.x, c1.y, c2.x, c2.y]
            return 'M 0 0'

        @d1 = @source_anchor or @source.direction(c2.x, c2.y)
        @a1 = @source.rotate(@source.anchors[@d1]())

        @d2 = @target_anchor or @target.direction(@a1.x, @a1.y)
        @a2 = @target.rotate(@target.anchors[@d2]())

        @d1 = @source_anchor or @source.direction(@a2.x, @a2.y)
        @a1 = @source.rotate(@source.anchors[@d1]())

        @d2 = @target_anchor or @target.direction(@a1.x, @a1.y)
        @a2 = @target.rotate(@target.anchors[@d2]())

        path = "M #{@a1.x} #{@a1.y}"
        vert = ['N', 'S']
        horz = ['E', 'W']

        if diagram.linkstyle == 'curve'
            path = "#{path} C"
            m =
                x: .5 * (@a1.x + @a2.x)
                y: .5 * (@a1.y + @a2.y)

            if @d1 in vert
                path = "#{path} #{@a1.x} #{m.y}"
            else
                path = "#{path} #{m.x} #{@a1.y}"

            if @d2 in vert
                path = "#{path} #{@a2.x} #{m.y}"
            else
                path = "#{path} #{m.x} #{@a2.y}"
        else if diagram.linkstyle == 'diagonal'
            path = "#{path} L"
        else if diagram.linkstyle == 'rectangular'
            path = "#{path} L"
            if @d1 in vert and @d2 in horz
                path = "#{path} #{@a1.x} #{@a2.y} L"
            else if @d1 in horz and @d2 in vert
                path = "#{path} #{@a2.x} #{@a1.y} L"
            else if @d1 in horz and @d2 in horz
                mid = @a1.x + .5 * (@a2.x - @a1.x)
                path = "#{path} #{mid} #{@a1.y} L #{mid} #{@a2.y} L"
            else if @d1 in vert and @d2 in vert
                mid = @a1.y + .5 * (@a2.y - @a1.y)
                path = "#{path} #{@a1.x} #{mid} L #{@a2.x} #{mid} L"

        "#{path} #{@a2.x} #{@a2.y}"
