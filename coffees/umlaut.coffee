class @Element
    constructor: (@x, @y, @text, @fixed=true) ->
        @_margin = x: 10, y: 5

    center: ->
        x: @x + (@_txt_bbox and @_txt_bbox.width or 0) / 2 + @_margin.x
        y: @y + (@_txt_bbox and @_txt_bbox.height or 0) / 2 + @_margin.y

    width: ->
        @_txt_bbox.width + 2 * @_margin.x

    height: ->
        @_txt_bbox.height + 2 * @_margin.y

    direction: (other) ->
        delta = @height() / @width()
        if @x <= other.x and @y <= other.y
            if other.y > delta * (other.x - @x) + @y
                return 'S'
            else
                return 'E'
        if @x >= other.x and @y <= other.y
            if other.y > delta * (@x - other.x) + @y
                return 'S'
            else
                return 'O'
        if @x <= other.x and @y >= other.y
            if other.y > delta * (@x - other.x) + @y
                return 'E'
            else
                return 'N'
        if @x >= other.x and @y>= other.y
            if other.y > delta * (other.x - @x) + @y
                return 'O'
            else
                return 'N'

    anchor: (other) ->
        rv =
            direction: @direction(other)
        switch rv.direction
            when 'N'
                rv.x = @x + @width() / 2
                rv.y = @y
            when 'S'
                rv.x = @x + @width() / 2
                rv.y = @y + @height()
            when 'E'
                rv.x = @x + @width()
                rv.y = @y + @height() / 2
            when 'O'
                rv.x = @x
                rv.y = @y + @height() / 2
        rv

    objectify: ->
        name: @constructor.name
        x: @x
        y: @y
        text: @text
        fixed: @fixed


class @Square extends Element
    path: ->
      "M 0 0 L #{@width()} 0 L #{@width()} #{@height()} L 0 #{@height()} z"

class @Lozenge extends Element
    path: ->
      "M -5 0 L #{@width() - 5} 0 L #{@width() + 5} #{@height()} L 5 #{@height()} z"

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
        source = @source()
        x1 = source.x
        y1 = source.y
        target = @target()
        x2 = target.x
        y2 = target.y
        path = "M #{x1} #{y1} C"
        xm = .5 * (x1 + x2)
        ym = .5 * (y1 + y2)

        if source.direction == 'N' or source.direction == 'S'
            path = "#{path} #{x1} #{ym}"
        else
            path = "#{path} #{xm} #{y1}"

        if target.direction == 'N' or target.direction == 'S'
            path = "#{path} #{x2} #{ym}"
        else
            path = "#{path} #{xm} #{y2}"

        "#{path} #{x2} #{y2}"



@data = data = {}
@state =
    selection: []
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


load = =>
    data.elts = []
    data.lnks = []
    for elt in JSON.parse(localStorage.getItem('elts') or '[]')
        data.elts.push(new @[elt.name](elt.x, elt.y, elt.text, elt.fixed))
    for lnk in JSON.parse(localStorage.getItem('lnks') or '[]')
        data.lnks.push(new @[lnk.name](data.elts[lnk.elt1], data.elts[lnk.elt2]))
    state.selection = []

save = =>
    localStorage.setItem('elts', JSON.stringify(data.elts.map((elt) -> elt.objectify())))
    localStorage.setItem('lnks', JSON.stringify(data.lnks.map((lnk) -> lnk.objectify())))

load()


article = d3.select("article")
width = article.node().clientWidth
height = article.node().clientHeight

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
        .attr('x', (elt) -> elt._margin.x)
        .attr('y', (elt) -> elt._margin.y)

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
    new_elt = new type(undefined, undefined, 'New element', false)
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

    square:
        fun: ->
            element_add Square
        label: 'Add square element'
        hotkey: 's'

    lozenge:
        fun: ->
            element_add Lozenge
        label: 'Add lozenge element'
        hotkey: 'z'

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
    )

sync()
