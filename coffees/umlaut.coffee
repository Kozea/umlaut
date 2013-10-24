class @Element
    constructor: (@x, @y, @text, @fixed=true) ->
        @margin = x: 10, y: 5

    pos: ->
        x: @x
        y: @y

    width: ->
        @_txt_bbox.width + 2 * @margin.x

    height: ->
        @_txt_bbox.height + 2 * @margin.y

    direction: (x, y) ->
        delta = @height() / @width()

        if @x <= x and @y <= y
            if y > delta * (x - @x) + @y
                return 'S'
            else
                return 'E'
        if @x >= x and @y <= y
            if y > delta * (@x - x) + @y
                return 'S'
            else
                return 'O'
        if @x <= x and @y >= y
            if y > delta * (@x - x) + @y
                return 'E'
            else
                return 'N'
        if @x >= x and @y >= y
            if y > delta * (x - @x) + @y
                return 'O'
            else
                return 'N'

    anchor: (direction) ->
        switch direction
            when 'N'
                x: @x
                y: @y - @height() / 2
            when 'S'
                x: @x
                y: @y + @height() / 2
            when 'E'
                x: @x + @width() / 2
                y: @y
            when 'O'
                x: @x - @width() / 2
                y: @y

    in: (rect) ->
        rect.x < @x < rect.x + rect.width and rect.y < @y < rect.y + rect.height

    objectify: ->
        name: @constructor.name
        x: @x
        y: @y
        text: @text
        fixed: @fixed

class Mouse extends Element
    width: -> 1
    height: -> 1
    weight: 1

E = {}
L = {}

class E.Process extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2} #{-h2}
         L #{w2} #{h2}
         L #{-w2} #{h2}
         z"

class E.DataIO extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        shift = 5

        "M #{-w2 - shift} #{-h2}
         L #{w2 - shift} #{-h2}
         L #{w2 + shift} #{h2}
         L #{-w2 + shift} #{h2}
         z"

class E.Terminator extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        shift = 10

        "M #{-w2 + shift} #{-h2}
         L #{w2 - shift} #{-h2}
         Q #{w2} #{-h2} #{w2} #{-h2 + shift}
         L #{w2} #{h2 - shift}
         Q #{w2} #{h2} #{w2 - shift} #{h2}
         L #{-w2 + shift} #{h2}
         Q #{-w2} #{h2} #{-w2} #{h2 - shift}
         L #{-w2} #{-h2 + shift}
         Q #{-w2} #{-h2} #{-w2 + shift} #{-h2}"

class E.Decision extends Element
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

class E.Delay extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        shift = 10

        "M #{-w2} #{-h2}
         L #{w2 - shift} #{-h2}
         Q #{w2} #{-h2} #{w2} #{-h2 + shift}
         L #{w2} #{h2 - shift}
         Q #{w2} #{h2} #{w2 - shift} #{h2}
         L #{-w2} #{h2}
         z"



class @Link
    constructor: (@source, @target) ->
        @lol = @target

    objectify: ->
        name: @constructor.name
        source: data.elts.indexOf(@source)
        target: data.elts.indexOf(@target)

    path: ->
        c1 = @source.pos()
        c2 = @target.pos()
        if undefined in [c1.x, c1.y, c2.x, c2.y]
            return 'M 0 0'
        d1 = @source.direction(c2.x, c2.y)
        d2 = @target.direction(c1.x, c1.y)

        a1 = @source.anchor(d1)
        a2 = @target.anchor(d2)

        path = "M #{a1.x} #{a1.y}"
        vert = ['N', 'S']
        horz = ['E', 'O']

        if state.linkstyle == 'curve'
            path = "#{path} C"
            m =
                x: .5 * (a1.x + a2.x)
                y: .5 * (a1.y + a2.y)

            if d1 in vert
                path = "#{path} #{a1.x} #{m.y}"
            else
                path = "#{path} #{m.x} #{a1.y}"

            if d2 in vert
                path = "#{path} #{a2.x} #{m.y}"
            else
                path = "#{path} #{m.x} #{a2.y}"
        else if state.linkstyle == 'diagonal'
            path = "#{path} L"
        else if state.linkstyle == 'rectangular'
            path = "#{path} L"
            if d1 in vert and d2 in horz
                path = "#{path} #{a1.x} #{a2.y} L"
            else if d1 in horz and d2 in vert
                path = "#{path} #{a2.x} #{a1.y} L"
            else if d1 in horz and d2 in horz
                mid = a1.x + .5 * (a2.x - a1.x)
                path = "#{path} #{mid} #{a1.y} L #{mid} #{a2.y} L"
            else if d1 in vert and d2 in vert
                mid = a1.y + .5 * (a2.y - a1.y)
                path = "#{path} #{a1.x} #{mid} L #{a2.x} #{mid} L"

        "#{path} #{a2.x} #{a2.y}"


@data = data = {}
@state =
    selection: []
    snap: 25
    no_save: false
    dragging: false
    mouse: new Mouse(0, 0, '')
    linking: []
    linkstyle: 'rectangular'
    freemode: false
    scale: 1
    translate: [0, 0]

mouse_xy = (e) ->
    m = d3.mouse(e)

    x: (m[0] - state.translate[0]) / state.scale
    y: (m[1] - state.translate[1]) / state.scale


objectify = ->
    JSON.stringify(
        elts: data.elts.map((elt) -> elt.objectify())
        lnks: data.lnks.map((lnk) -> lnk.objectify())
    )

load = (new_data) =>
    data.elts = []
    data.lnks = []

    new_data = JSON.parse(new_data)
    for elt in new_data.elts
        data.elts.push(new E[elt.name](elt.x, elt.y, elt.text, elt.fixed))
    for lnk in new_data.lnks
        data.lnks.push(new @[lnk.name](data.elts[lnk.source], data.elts[lnk.target]))

    state.selection = []

save = =>
    localStorage.setItem('data', objectify())


generate_url = ->
    if state.no_save
        state.no_save = false
        return
    hash = '#' + btoa(objectify())
    if location.hash != hash
        history.pushState(null, null, hash)

commands =
    reorganize:
        fun: ->
            sel = if state.selection.length > 0 then state.selection else data.elts
            for elt in sel
                elt.fixed = false
            sync()
        label: 'Reorganize'
        hotkey: 'r'

    link:
        fun: ->
            state.linking = []
            for elt in state.selection
                state.linking.push(new Link(elt, state.mouse))
            sync()
        label: 'Link elements'
        hotkey: 'l'

    edit:
        fun: ->
            for elt in state.selection
                elt.text = prompt("Enter a name for #{elt.text}:", elt.text) or elt.text
            sync()
        label: 'Edit element text'
        hotkey: 'e'


    select_all:
        fun: (e) ->
            state.selection = data.elts.slice()
            d3.selectAll('g.element').classed('selected', true)
            e?.preventDefault()

        label: 'Select all elements'
        hotkey: 'ctrl+a'

    save:
        fun: (e) ->
            save()
            e?.preventDefault()

        label: 'Save locally'
        hotkey: 'ctrl+s'

    load:
        fun: (e) ->
            load(localStorage.getItem('data') or '')
            sync()
            e?.preventDefault()

        label: 'Load locally'
        hotkey: 'ctrl+l'

    undo:
        fun: (e) ->
            history.go(-1)
            e?.preventDefault()

        label: 'Undo'
        hotkey: 'ctrl+z'

    redo:
        fun: (e) ->
            history.go(1)
            e?.preventDefault()

        label: 'Redo'
        hotkey: 'ctrl+y'

    remove:
        fun: ->
            for elt in state.selection
                data.elts.splice(data.elts.indexOf(elt), 1)
                for lnk in data.lnks.slice()
                    if elt == lnk.source or elt == lnk.target
                        data.lnks.splice(data.lnks.indexOf(lnk), 1)
            state.selection = []
            d3.selectAll('g.element').classed('selected', false)
            sync()
        label: 'Remove elements'
        hotkey: 'del'

    linkstyle:
        fun: ->
            state.linkstyle = switch state.linkstyle
                when 'curve' then 'diagonal'
                when 'diagonal' then 'rectangular'
                when 'rectangular' then 'curve'
            tick()
        label: 'Change link style'
        hotkey: 'space'

    freemode:
        fun: ->
            for elt in data.elts
                elt.fixed = state.freemode
            if state.freemode
                force.stop()
            else
                sync()
            state.freemode = not state.freemode
        label: 'Toggle free mode'
        hotkey: 'tab'

    recenter:
        fun: ->
            zoom.translate([0, 0])
            zoom.event(underlay_g)
        label: 'Recenter'
        hotkey: 'ctrl+home'

    defaultscale:
        fun: ->
            zoom.scale(1)
            zoom.event(underlay_g)
        label: 'Default zoom'
        hotkey: 'ctrl+0'

    defaultscale:
        fun: ->
            zoom.scale(1)
            zoom.translate([0, 0])
            zoom.event(underlay_g)
        label: 'Reset view'
        hotkey: 'ctrl+backspace'

    snaptogrid:
        fun: ->
            for elt in data.elts
                elt.x = elt.px = state.snap * Math.floor(elt.x / state.snap)
                elt.y = elt.py = state.snap * Math.floor(elt.y / state.snap)
            tick()
        label: 'Snap to grid'
        hotkey: 'ctrl+space'


taken_hotkeys = []
for e of E
    i = 1
    key = e[0].toLowerCase()
    while i < e.length and key in taken_hotkeys
        key = e[i++].toLowerCase()

    taken_hotkeys.push(key)

    commands[e] =
        ((elt) ->
            fun: ->
                element_add elt
            label: elt
            hotkey: "a #{key}")(e)

aside = d3.select('aside')

for name, command of commands
    aside
        .append('button')
        .attr('title', "#{command.label} [#{command.hotkey}]")
        .text(command.label)
        .on 'click', command.fun
    Mousetrap.bind command.hotkey, command.fun

article = d3.select("article")
width = article.node().clientWidth
height = article.node().clientHeight or 500

svg = article
    .append("svg")
    .attr("width", width)
    .attr("height", height)

underlay_g = svg
    .append('g')

underlay = underlay_g
    .append('rect')
    .attr('class', 'underlay')
    .attr('width', width)
    .attr('height', height)
    .attr('fill', 'url(#grid)')

d3.select(@).on('resize', ->
    width = article.node().clientWidth
    height = article.node().clientHeight or 500
    svg
        .attr("width", width)
        .attr("height", height)
    underlay
        .attr("width", width)
        .attr("height", height)
)

root = underlay_g
    .append('g')
    .attr('class', 'root')

defs = svg
    .append('svg:defs')

defs
    .append('svg:marker')
    .attr('id', 'arrow')
    .attr('viewBox', '0 0 10 10')
    .attr('refX', 10)
    .attr('refY', 5)
    .attr('markerUnits', 'strokeWidth')
    .attr('markerWidth', 10)
    .attr('markerHeight', 10)
    .attr('orient', 'auto')
    .append('svg:path')
    .attr('d', 'M 0 0 L 10 5 L 0 10')

pattern = defs
    .append('svg:pattern')
    .attr('id', 'grid')
    .attr('viewBox', '0 0 10 10')
    .attr('x', 0)
    .attr('y', 0)
    .attr('width', state.snap)
    .attr('height', state.snap)
    .attr('patternUnits', 'userSpaceOnUse')

pattern
    .append('svg:path')
    .attr('d', 'M 10 0 L 0 0 L 0 10')

force = d3.layout.force()
    .gravity(.2)
    .linkDistance(300)
    .charge(-5000)
    .size([width, height])

drag = force.drag()
    .on("drag.force", (elt) ->
        return if not state.dragging or d3.event.sourceEvent.ctrlKey

        if not elt in state.selection
            state.selection.push elt

        if d3.event.sourceEvent.shiftKey
            delta =
                x: elt.px - d3.event.x
                y: elt.py - d3.event.y
        else
            delta =
                x: elt.px - state.snap * Math.floor(d3.event.x / state.snap)
                y: elt.py - state.snap * Math.floor(d3.event.y / state.snap)

        for elt in state.selection
            elt.px -= delta.x
            elt.py -= delta.y

        force.resume()
    ).on('dragstart', ->
        return if d3.event.sourceEvent.which is 3 or d3.event.sourceEvent.ctrlKey
        state.dragging = true
    ).on('dragend', (elt) ->
        state.dragging = false
        if not state.freemode
            elt.fixed = true
    )

element = null
link = null

svg.on("mousedown", ->
    return if state.dragging or d3.event.ctrlKey

    if d3.event.which is 3
        state.linking = []
        for elt in state.selection
             state.linking.push(new Link(elt, state.mouse))
        sync()
    else
        if not d3.event.shiftKey
            d3.selectAll('.selected').classed('selected', false)
            state.selection = []

        mouse = mouse_xy(@)
        svg.select('g.overlay')
            .append("rect").attr
                class: "selection"
                x: mouse.x
                y: mouse.y
                width: 0
                height: 0
    d3.event.preventDefault()
).on('contextmenu', ->
    d3.event.preventDefault()
)

d3.select(@).on("mousemove", ->
    return if d3.event.ctrlKey
    mouse = mouse_xy(svg.node())
    state.mouse.x = mouse.x
    state.mouse.y = mouse.y
    if state.linking.length
        tick()
        return

    sel = svg.select("rect.selection")
    unless sel.empty()
        rect =
            x: + sel.attr("x")
            y: + sel.attr("y")
            width: + sel.attr("width")
            height: + sel.attr("height")

        move =
            x: mouse.x - rect.x
            y: mouse.y - rect.y

        if move.x < 1 or (move.x * 2 < rect.width)
            rect.x = mouse.x
            rect.width -= move.x
        else
            rect.width = move.x
        if move.y < 1 or (move.y * 2 < rect.height)
            rect.y = mouse.y
            rect.height -= move.y
        else
            rect.height = move.y
        sel.attr rect
        d3.selectAll('g.element').each((elt) ->
            g = d3.select @
            selected = g.classed 'selected'
            if elt.in(rect) and not selected
                state.selection.push(elt)
                g.classed 'selected', true
            else if not elt.in(rect) and selected and not d3.event.shiftKey
                state.selection.splice(state.selection.indexOf(elt), 1)
                g.classed 'selected', false
        )
        d3.event.preventDefault()

).on("mouseup", ->
    return if d3.event.ctrlKey
    if state.linking.length
        state.linking = []
        sync()

    svg.selectAll("rect.selection").remove()
    d3.event.preventDefault()
).on("keydown", ->
    if d3.event.ctrlKey
        underlay.classed('move', true)
).on("keyup", ->
    underlay.classed('move', false)
)


root
    .append('g')
    .attr('class', 'links')

root
    .append('g')
    .attr('class', 'elements')

root
    .append('g')
    .attr('class', 'overlay')

zoom = d3.behavior.zoom()
    .scale(1)
    .on("zoom", ->
        if not d3.event.sourceEvent or d3.event.sourceEvent.type in ['wheel', 'click'] or d3.event.sourceEvent.ctrlKey
            state.translate = d3.event.translate
            state.scale = d3.event.scale
            root.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
            pattern.attr("patternTransform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
        else
            zoom.scale(state.scale)
            zoom.translate(state.translate)
    )

underlay_g.call(zoom)

sync = ->
    force.nodes(data.elts)
        .links(data.lnks)

    link = svg.select('g.links').selectAll('path.link')
        .data(data.lnks.concat(state.linking))

    link
        .enter()
            .append("path")
            .attr("class", "link")
            .attr("marker-end", "url(#arrow)")

    element = svg.select('g.elements')
        .selectAll('g.element')
        .data(data.elts)


    # Update

    # Enter
    g = element.enter()
        .append('g')
        .attr('class', 'element')
        .call(drag)
        .on("mousedown", (elt) ->
            return if d3.event.ctrlKey
            g = d3.select @
            selected = g.classed 'selected'
            if (selected and not state.dragging) or (not selected) and not d3.event.shiftKey
                d3.selectAll('.selected').classed('selected', false)
                state.selection = [elt]
                d3.select(this).classed('selected', true)

            if d3.event.shiftKey and not selected
                d3.select(this).classed('selected', true)
                state.selection.push(elt))
        .on("mousemove", (elt) ->
            return if d3.event.ctrlKey
            for lnk in state.linking
                lnk.target = elt)
        .on("mouseout", (elt) ->
            return if d3.event.ctrlKey
            for lnk in state.linking
                lnk.target = state.mouse)
        .on("mouseup", (elt) ->
            return if d3.event.ctrlKey
            if state.linking.length
                for lnk in state.linking
                    if lnk.source != elt
                        data.lnks.push(new Link(lnk.source, elt))
                state.linking = []
                sync()
                d3.event.preventDefault())
        .on('dblclick', (elt) ->
            return if d3.event.ctrlKey
            elt.text = prompt("Enter a name for #{elt.text}:", elt.text) or elt.text
            sync())

    g
        .append('path')
        .attr('class', 'shape')
    g
        .append('text')

    # Update + Enter
    element
        .select('text')
        .text((elt) -> elt.text)
        .each((elt) -> elt._txt_bbox = @getBBox())

    element
        .select('path.shape')
        .attr('d', (elt) -> elt.path())

    # Exit
    element.exit()
        .remove()

    link.exit()
        .remove()

    tick()

    force.start()



tick = ->
    need_force = false

    for elt in data.elts
        if not elt.fixed
            need_force = true
            break

    need_force = need_force and (state.freemode or (force.alpha() or 1) > .03)

    if not need_force
        force.stop()

    element
        .attr("transform", ((elt) -> "translate(" + elt.x + "," + elt.y + ")"))
        .each((elt) -> d3.select(this).classed('moving', not elt.fixed))
    link
        .attr("d", (elt) -> elt.path())


element_add = (type) =>
    new_elt = new E[type](undefined, undefined, 'New element', false)
    data.elts.push(new_elt)
    for elt in state.selection
        data.lnks.push(new Link(elt, new_elt))
    sync()

force
    .on('tick', tick)
    .on('end', ->
        if not state.freemode
            for elt in data.elts
                elt.fixed = true
        # Last adjustements
        tick()
        generate_url()
    )


history_pop = () ->
    try
        if location.hash
            load(atob(location.hash.slice(1)))
        else
            local_data = localStorage.getItem('data')
            if not local_data
                local_data = atob('eyJlbHRzIjpbeyJuYW1lIjoiUHJvY2VzcyIsIngiOjIwMCwieSI6NzUsInRleHQiOiJTdGFydCIsImZpeGVkIjp0cnVlfSx7Im5hbWUiOiJEZWNpc2lvbiIsIngiOjIwMCwieSI6MjI1LCJ0ZXh0IjoiRG8geW91IHVuZGVyc3RhbmQgZmxvdyBjaGFydHM/IiwiZml4ZWQiOnRydWV9LHsibmFtZSI6IlByb2Nlc3MiLCJ4Ijo2NzUsInkiOjIyNSwidGV4dCI6Ikdvb2QiLCJmaXhlZCI6dHJ1ZX0seyJuYW1lIjoiUHJvY2VzcyIsIngiOjEwMjUsInkiOjIyNSwidGV4dCI6IkxldCdzIGdvIGRyaW5rLiIsImZpeGVkIjp0cnVlfSx7Im5hbWUiOiJQcm9jZXNzIiwieCI6MTAyNSwieSI6MTAwLCJ0ZXh0IjoiSGV5IEkgc2hvdWxkIHRyeSBpbnN0YWxsaW5nIEZyZWVCU0QhIiwiZml4ZWQiOnRydWV9LHsibmFtZSI6IkRlY2lzaW9uIiwieCI6MjAwLCJ5Ijo0MjUsInRleHQiOiJPa2F5LiBZb3Ugc2VlIHRoZSBsaW5lIGxhYmVsZWQgXCJ5ZXNcIj8iLCJmaXhlZCI6dHJ1ZX0seyJuYW1lIjoiRGVjaXNpb24iLCJ4IjoyMDAsInkiOjU3NSwidGV4dCI6IkJ1dCB5b3Ugc2VlIHRoZSBvbmVzIGxhYmVsZWQgXCJub1wiLiIsImZpeGVkIjp0cnVlfSx7Im5hbWUiOiJQcm9jZXNzIiwieCI6MjAwLCJ5Ijo3MDAsInRleHQiOiJMaXN0ZW4uIiwiZml4ZWQiOnRydWV9LHsibmFtZSI6IlByb2Nlc3MiLCJ4IjozNTAsInkiOjcwMCwidGV4dCI6IkkgaGF0ZSB5b3UiLCJmaXhlZCI6dHJ1ZX0seyJuYW1lIjoiUHJvY2VzcyIsIngiOjUyNSwieSI6NjUwLCJ0ZXh0IjoiV2FpdCwgd2hhdD8iLCJmaXhlZCI6dHJ1ZX0seyJuYW1lIjoiRGVjaXNpb24iLCJ4Ijo2NzUsInkiOjQyNSwidGV4dCI6Ii4uLmFuZCB5b3UgY2FuIHNlZSB0aGUgb25lcyBsYWJlbGVkIFwibm9cIj8iLCJmaXhlZCI6dHJ1ZX0seyJuYW1lIjoiRGVjaXNpb24iLCJ4Ijo2NzUsInkiOjU3NSwidGV4dCI6IkJ1dCB5b3UganVzdCBmb2xsb3dlZCB0aGVtIHR3aWNlISIsImZpeGVkIjp0cnVlfSx7Im5hbWUiOiJQcm9jZXNzIiwieCI6MTAyNSwieSI6NTc1LCJ0ZXh0IjoiKFRoYXQgd2Fzbid0IGEgcXVlc3Rpb24uKSIsImZpeGVkIjp0cnVlfSx7Im5hbWUiOiJQcm9jZXNzIiwieCI6MTAyNSwieSI6NDUwLCJ0ZXh0IjoiU2NyZXcgaXQuIiwiZml4ZWQiOnRydWV9XSwibG5rcyI6W3sibmFtZSI6IkxpbmsiLCJzb3VyY2UiOjAsInRhcmdldCI6MX0seyJuYW1lIjoiTGluayIsInNvdXJjZSI6MSwidGFyZ2V0IjoyfSx7Im5hbWUiOiJMaW5rIiwic291cmNlIjoyLCJ0YXJnZXQiOjN9LHsibmFtZSI6IkxpbmsiLCJzb3VyY2UiOjMsInRhcmdldCI6NH0seyJuYW1lIjoiTGluayIsInNvdXJjZSI6MSwidGFyZ2V0Ijo1fSx7Im5hbWUiOiJMaW5rIiwic291cmNlIjo1LCJ0YXJnZXQiOjZ9LHsibmFtZSI6IkxpbmsiLCJzb3VyY2UiOjYsInRhcmdldCI6N30seyJuYW1lIjoiTGluayIsInNvdXJjZSI6NywidGFyZ2V0Ijo4fSx7Im5hbWUiOiJMaW5rIiwic291cmNlIjo2LCJ0YXJnZXQiOjl9LHsibmFtZSI6IkxpbmsiLCJzb3VyY2UiOjUsInRhcmdldCI6MTB9LHsibmFtZSI6IkxpbmsiLCJzb3VyY2UiOjEwLCJ0YXJnZXQiOjExfSx7Im5hbWUiOiJMaW5rIiwic291cmNlIjoxMSwidGFyZ2V0IjoxMn0seyJuYW1lIjoiTGluayIsInNvdXJjZSI6MTIsInRhcmdldCI6MTN9LHsibmFtZSI6IkxpbmsiLCJzb3VyY2UiOjEzLCJ0YXJnZXQiOjN9LHsibmFtZSI6IkxpbmsiLCJzb3VyY2UiOjEwLCJ0YXJnZXQiOjJ9XX0=')
             load(local_data)
    catch
        data.elts = []
        data.lnks = []
    state.no_save = true
    sync()

@addEventListener("popstate", history_pop)


# ff hack
if @mozInnerScreenX != null
    history_pop()
