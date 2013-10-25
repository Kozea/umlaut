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



aside = d3.select('aside')


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
    if not d3.event.shiftKey
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
    .scaleExtent([.15, 5])
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

    link = svg.select('g.links').selectAll('g.link')
        .data(data.lnks.concat(state.linking))

    link_g = link.enter()
        .append('g')
        .attr("class", "link")

    link_g
        .append("path")
        .attr("marker-end", "url(#arrow)")

    link_g
        .append("text")
        .attr('class', "start")

    link_g
        .append("text")
        .attr('class', "end")

    element = svg.select('g.elements')
        .selectAll('g.element')
        .data(data.elts)

    # Update

    # Enter
    element_g = element.enter()
        .append('g')
        .attr('class', 'element')
        .call(drag)
        .on("mousedown", (elt) ->
            return if d3.event.ctrlKey
            element_g = d3.select @
            selected = element_g.classed 'selected'
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
            edit(elt))

    element_g
        .append('path')
        .attr('class', 'shape')

    element_g
        .append('text')

    # Update + Enter
    link
        .select('text.start')
        .each((lnk) ->
            return if not lnk.text_source
            txt = d3.select @
            txt.selectAll('tspan').remove()
            for line, i in lnk.text_source.split('\n')
                tspan = txt.append('tspan')
                    .text(line)
                if i != 0
                    tspan
                        .attr('dy', '1.2em'))
        .each((lnk) -> lnk._txt_bbox = @getBBox())
        .attr('x', (lnk) -> lnk.a1.x)
        .attr('y', (lnk) -> lnk.a1.y)

    link
        .select('text.end')
        .each((lnk) ->
            return if not lnk.text_target
            txt = d3.select @
            txt.selectAll('tspan').remove()
            for line, i in lnk.target.split('\n')
                tspan = txt.append('tspan')
                    .text(line)
                if i != 0
                    tspan
                        .attr('dy', '1.2em'))
        .each((lnk) -> lnk._txt_bbox = @getBBox())
        .attr('x', (lnk) -> lnk.a2.x)
        .attr('y', (lnk) -> lnk.a2.y)

    element
        .select('text')
        .each((elt) ->
            txt = d3.select @
            txt.selectAll('tspan').remove()
            for line, i in elt.text.split('\n')
                tspan = txt.append('tspan')
                    .text(line)
                    .attr('x', 0)
                if i != 0
                    tspan
                        .attr('dy', '1.2em'))
        .each((elt) -> elt._txt_bbox = @getBBox())
        .attr('y', (elt) -> - elt._txt_bbox.height / 2)

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
        .select('path')
        .attr("d", (lnk) -> lnk.path())


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
             load(localStorage.getItem('data'))
    catch
        data.elts = []
        data.lnks = []
    state.no_save = true
    sync()

@addEventListener("popstate", history_pop)


# ff hack
if @mozInnerScreenX != null
    history_pop()
 
