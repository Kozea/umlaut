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

    anchor: (x, y) ->
        rv =
            direction: @direction(x, y)
        switch rv.direction
            when 'N'
                rv.x = @x
                rv.y = @y - @height() / 2
            when 'S'
                rv.x = @x
                rv.y = @y + @height() / 2
            when 'E'
                rv.x = @x + @width() / 2
                rv.y = @y
            when 'O'
                rv.x = @x - @width() / 2
                rv.y = @y
        rv

    objectify: ->
        name: @constructor.name
        x: @x
        y: @y
        text: @text
        fixed: @fixed

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
    constructor: (@elt1, @elt2) ->

    source: =>
        @elt1.anchor(@elt2)

    target: =>
        @elt2.anchor(@elt1)

    objectify: ->
        name: @constructor.name
        elt1: data.elts.indexOf(@elt1)
        elt2: data.elts.indexOf(@elt2)

    path: ->
        c1 = @elt1.pos()
        c2 = @elt2.pos()

        a1 = @elt1.anchor(c2.x, c2.y)
        a2 = @elt2.anchor(c1.x, c1.y)

        path = "M #{a1.x} #{a1.y} C"
        m =
            x: .5 * (a1.x + a2.x)
            y: .5 * (a1.y + a2.y)

        if a1.direction == 'N' or a1.direction == 'S'
            path = "#{path} #{a1.x} #{m.y}"
        else
            path = "#{path} #{m.x} #{a1.y}"

        if a2.direction == 'N' or a2.direction == 'S'
            path = "#{path} #{a2.x} #{m.y}"
        else
            path = "#{path} #{m.x} #{a2.y}"

        "#{path} #{a2.x} #{a2.y}"



@data = data = {}
@state =
    selection: []
    snap: 25
    no_save: false
    mouse:
        x: 0
        y: 0


@combinations = (elts, n) ->
    return [] if elts.length < n
    return [elts] if elts.length == n
    result = []
    f = (prefix, elts) ->
        i = 0

        while i < elts.length
            combination = prefix.concat(elts[i])
            if combination.length == n
                result.push combination
            f combination, elts.slice(i + 1)
            i++

    f [], elts
    result


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
        data.lnks.push(new @[lnk.name](data.elts[lnk.elt1], data.elts[lnk.elt2]))

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
    .linkDistance(100)
    .charge(-2000)
    .size([width, height])

drag = force.drag()
    .on("dragstart", (elt) ->
        if d3.event.sourceEvent.shiftKey
            state.selection.push(elt)
        else
            d3.selectAll('.selected').classed('selected', false)
            state.selection = [elt]

        d3.select(this).classed('selected', true)
    )
    .on("drag.force", (elt) ->
        if d3.event.sourceEvent.shiftKey
            elt.px = d3.event.x
            elt.py = d3.event.y
        else
            elt.px = state.snap * Math.floor(d3.event.x / state.snap)
            elt.py = state.snap * Math.floor(d3.event.y / state.snap)
        force.resume()
    )

element = null
link = null

svg
    .on('click', ->
        if d3.event.target == @
            d3.selectAll('.selected').classed('selected', false)
            state.selection = []
    )
svg
    .append('g')
    .attr('class', 'links')

svg
    .append('g')
    .attr('class', 'elements')


sync = ->
    force.nodes(data.elts)
        .links(data.lnks)

    link = svg.select('g.links').selectAll('path.link')
        .data(data.lnks)

    link
        .enter()
            .append("path")
            .attr("class", "link")
            .attr("marker-end", "url(#arrow)")
            .on('click', ->
                d3.select(this).classed('selected', true))

    element = svg.select('g.elements').selectAll('g.element')
        .data(data.elts)


    # Update

    # Enter
    g = element.enter()
        .append('g')
        .attr('class', 'element')
        .call(drag)
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
            for combination in combinations(state.selection, 2)
                data.lnks.push(new Link(combination[0], combination[1]))
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
                    if elt == lnk.elt1 or elt == lnk.elt2
                        data.lnks.splice(data.lnks.indexOf(lnk), 1)
            state.selection = []
            d3.selectAll('g.element').classed('selected', false)
            sync()
        label: 'Remove elements'
        hotkey: 'del'

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
