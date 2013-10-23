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

        d1 = @source.direction(c2.x, c2.y)
        d2 = @target.direction(c1.x, c1.y)

        a1 = @source.anchor(d1)
        a2 = @target.anchor(d2)

        path = "M #{a1.x} #{a1.y}"
        if state.linkstyle == 'curve'
            path = "#{path} C"
            m =
                x: .5 * (a1.x + a2.x)
                y: .5 * (a1.y + a2.y)

            if d1 == 'N' or d1 == 'S'
                path = "#{path} #{a1.x} #{m.y}"
            else
                path = "#{path} #{m.x} #{a1.y}"

            if d2 == 'N' or d2 == 'S'
                path = "#{path} #{a2.x} #{m.y}"
            else
                path = "#{path} #{m.x} #{a2.y}"
        else if state.linkstyle == 'diagonal'
            path = "#{path} L"
        else if state.linkstyle == 'rectangular'
            path = "#{path} L"
            path = "#{path} #{a1.x} #{a2.y} L"

        "#{path} #{a2.x} #{a2.y}"


@data = data = {}
@state =
    selection: []
    snap: 25
    no_save: false
    dragging: false
    mouse: new Mouse(0, 0, '')
    linking: []
    linkstyle: 'curve'

objectify = ->
    JSON.stringify(
        elts: data.elts.map((elt) -> elt.objectify())
        lnks: data.lnks.map((lnk) -> lnk.objectify())
    )

load = (new_data=null) =>
    data.elts = []
    data.lnks = []
    new_data = new_data or localStorage.getItem('data')
    if not new_data
        return

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
                elt.text = prompt("Enter a name for #{elt.text}:")
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
            load()
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

for e of E
    commands[e] =
        ((elt) ->
            fun: ->
                element_add elt
            label: elt
            hotkey: elt[0])(e)

aside = d3.select('aside')

for name, command of commands
    aside
        .append('button')
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

svg
    .append("svg:defs")
    .append("svg:marker")
    .attr("id", 'arrow')
    .attr("viewBox", "0 0 10 10")
    .attr("refX", 10)
    .attr("refY", 5)
    .attr("markerUnits", 'strokeWidth')
    .attr("markerWidth", 10)
    .attr("markerHeight", 10)
    .attr("orient", "auto")
    .append("svg:path")
    .attr("d", "M 0 0 L 10 5 L 0 10")


force = d3.layout.force()
    .gravity(.2)
    .linkDistance(300)
    .charge(-2000)
    .size([width, height])

drag = force.drag()
    .on("drag.force", (elt) ->
        return if not state.dragging

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
        unless d3.event.sourceEvent.which is 3
            state.dragging = true
    ).on('dragend', ->
        state.dragging = false
    )

element = null
link = null

svg.on("mousedown", ->
    return if state.dragging

    if d3.event.which is 3
        state.linking = []
        for elt in state.selection
             state.linking.push(new Link(elt, state.mouse))
        sync()
    else
        if not d3.event.shiftKey
            d3.selectAll('.selected').classed('selected', false)
            state.selection = []

        mouse = d3.mouse(@)
        svg.select('g.overlay')
            .append("rect").attr
                class: "selection"
                x: mouse[0]
                y: mouse[1]
                width: 0
                height: 0
    d3.event.preventDefault()
).on('contextmenu', ->
    d3.event.preventDefault()
)

d3.select(@).on("mousemove", ->
    mouse = d3.mouse(svg.node())
    state.mouse.x = mouse[0]
    state.mouse.y = mouse[1]
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
            x: mouse[0] - rect.x
            y: mouse[1] - rect.y

        if move.x < 1 or (move.x * 2 < rect.width)
            rect.x = mouse[0]
            rect.width -= move.x
        else
            rect.width = move.x
        if move.y < 1 or (move.y * 2 < rect.height)
            rect.y = mouse[1]
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
    if state.linking.length
        state.linking = []
        sync()

    svg.selectAll("rect.selection").remove()
    d3.event.preventDefault()
)

svg
    .append('g')
    .attr('class', 'underlay')

svg
    .append('g')
    .attr('class', 'links')

svg
    .append('g')
    .attr('class', 'elements')

svg
    .append('g')
    .attr('class', 'overlay')

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

    element = svg.select('g.elements').selectAll('g.element')
        .data(data.elts)


    # Update

    # Enter
    g = element.enter()
        .append('g')
        .attr('class', 'element')
        .call(drag)
        .on("mouseup", (elt) ->
            if state.linking.length
                for lnk in state.linking
                    if lnk.source != elt
                        data.lnks.push(new Link(lnk.source, elt))
                state.linking = []
                sync()
                d3.event.preventDefault())
        .on("mousedown", (elt) ->
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
            for lnk in state.linking
                lnk.target = elt)
        .on("mouseout", (elt) ->
            for lnk in state.linking
                lnk.target = state.mouse)
        .on('dblclick', (elt) ->
            elt.text = prompt("Enter a name for #{elt.text}:")
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

    need_force = need_force and (force.alpha() or 1) > .03

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
            load()
    catch
        data.elts = []
        data.lnks = []
    state.no_save = true
    sync()

@addEventListener("popstate", history_pop)


# ff hack
if @mozInnerScreenX != null
    history_pop()
