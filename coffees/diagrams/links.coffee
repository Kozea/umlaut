class Link
    text_margin: 10

    constructor: (@source, @target, text) ->
        @a1 = @a2 = 0
        @text =
            source: text?.source or ''
            target: text?.target or ''

    objectify: ->
        name: @constructor.name
        source: diagram.elements.indexOf(@source)
        target: diagram.elements.indexOf(@target)
        text: @text

    nearest: (pos) ->
        if dist(pos, @source) < dist(pos, @target) then @source else @target

    path: ->
        c1 = @source.pos()
        c2 = @target.pos()
        if undefined in [c1.x, c1.y, c2.x, c2.y]
            return 'M 0 0'
        @d1 = @source.direction(c2.x, c2.y)
        @d2 = @target.direction(c1.x, c1.y)

        @a1 = @source.anchor(@d1)
        @a2 = @target.anchor(@d2)

        path = "M #{@a1.x} #{@a1.y}"
        vert = ['N', 'S']
        horz = ['E', 'O']

        if state.linkstyle == 'curve'
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
        else if state.linkstyle == 'diagonal'
            path = "#{path} L"
        else if state.linkstyle == 'rectangular'
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
