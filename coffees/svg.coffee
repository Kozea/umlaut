class State
    constructor: ->
        @selection = []
        @snap = 25
        @no_save = false
        @dragging = false
        @mouse = new Mouse(0, 0, '')
        @linking = []
        @freemode = false
        @scale = 1
        @translate = [0, 0]


state = new State()


mouse_xy = (e) ->
    m = d3.mouse(e)

    x: (m[0] - state.translate[0]) / state.scale
    y: (m[1] - state.translate[1]) / state.scale


class Svg
    constructor: ->
        @aside = d3.select('aside')
        @article = d3.select("article")
        @width = @article.node().clientWidth
        @height = @article.node().clientHeight or 500
        @title = d3.select('#editor h2')
            .on('dblclick', ->
                edit((-> diagram.title), ((txt) -> diagram.title = txt))
        )

        @svg = @article
            .append("svg")
            .attr("width", @width)
            .attr("height", @height)

        @underlay_g = @svg
            .append('g')

        @underlay = @underlay_g
            .append('rect')
            .attr('class', 'underlay')
            .attr('width', @width)
            .attr('height', @height)
            .attr('fill', 'url(#grid)')

        d3.select(window).on('resize', => @resize())

        @defs = @svg
            .append('svg:defs')

        @defs
            .append('svg:marker')
            .attr('id', 'arrow')
            .attr('viewBox', '0 0 10 10')
            .attr('refX', 10)
            .attr('refY', 5)
            .attr('markerUnits', 'userSpaceOnUse')
            .attr('markerWidth', 10)
            .attr('markerHeight', 10)
            .attr('orient', 'auto')
            .append('svg:path')
            .attr('d', 'M 0 0 L 10 5 L 0 10')

        @pattern = @defs
            .append('svg:pattern')
            .attr('id', 'grid')
            .attr('viewBox', '0 0 10 10')
            .attr('x', 0)
            .attr('y', 0)
            .attr('width', state.snap)
            .attr('height', state.snap)
            .attr('patternUnits', 'userSpaceOnUse')

        @pattern
            .append('svg:path')
            .attr('d', 'M 10 0 L 0 0 L 0 10')

        @root = @underlay_g
            .append('g')
            .attr('class', 'root')

        @force = d3.layout.force()
            .gravity(.2)
            .linkDistance(300)
            .charge(-5000)
            .size([@width, @height])

        @drag = @force.drag()
            .on("drag.force", (elt) =>
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

                @force.resume()
            ).on('dragstart', ->
                return if d3.event.sourceEvent.which is 3 or d3.event.sourceEvent.ctrlKey
                state.dragging = true
            ).on('dragend', (elt) ->
                state.dragging = false
                if not state.freemode
                    elt.fixed = true
            )

        @element = null
        @link = null

        @svg.on("mousedown", (event) =>
            return if state.dragging or d3.event.ctrlKey or d3.event.which is 2

            if d3.event.which is 3
                state.linking = []
                for elt in state.selection
                     state.linking.push(new Arrow(elt, state.mouse))
                @sync()
            else
                if not d3.event.shiftKey
                    d3.selectAll('.selected').classed('selected', false)
                    state.selection = []

                mouse = mouse_xy(@svg.node())
                @svg.select('g.overlay')
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

        d3.select(window).on("mousemove", =>
            return if d3.event.ctrlKey
            mouse = mouse_xy(@svg.node())
            state.mouse.x = mouse.x
            state.mouse.y = mouse.y
            if state.linking.length
                @tick()
                return

            sel = @svg.select("rect.selection")
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

        ).on("mouseup", =>
            return if d3.event.ctrlKey
            if state.linking.length
                state.linking = []
                @sync()

            @svg.selectAll("rect.selection").remove()
            d3.event.preventDefault()
        ).on("keydown", =>
            if d3.event.ctrlKey
                @underlay.classed('move', true)
        ).on("keyup", =>
            @underlay.classed('move', false)
        )

        @root
            .append('g')
            .attr('class', 'links')

        @root
            .append('g')
            .attr('class', 'elements')

        @root
            .append('g')
            .attr('class', 'overlay')

        @zoom = d3.behavior.zoom()
            .scale(1)
            .scaleExtent([.15, 5])
            .on("zoom", =>
                if not d3.event.sourceEvent or d3.event.sourceEvent.type in ['wheel', 'click'] or d3.event.sourceEvent.ctrlKey or d3.event.sourceEvent.which is 2
                    state.translate = d3.event.translate
                    state.scale = d3.event.scale
                    @root.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
                    @pattern.attr("patternTransform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
                else
                    @zoom.scale(state.scale)
                    @zoom.translate(state.translate)
            )

        @underlay_g.call(@zoom)

        @force
            .on('tick', @tick)
            .on('end', =>
                if not state.freemode
                    for elt in diagram.elements
                        elt.fixed = true
                # Last adjustements
                @tick()
                generate_url()
            )

    sync: ->
        @force.nodes(diagram.elements)
            .links(diagram.links)

        @link = @svg.select('g.links').selectAll('g.link')
            .data(diagram.links.concat(state.linking))

        @title.text(diagram.title)

        link_g = @link.enter()
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

        link_g
            .on('dblclick', (lnk) ->
                return if d3.event.ctrlKey
                nearest = lnk.nearest state.mouse
                if nearest is lnk.source
                    edit((-> lnk.text.source), ((txt) -> lnk.text.source = txt))
                else
                    edit((-> lnk.text.target), ((txt) -> lnk.text.target = txt)))

        @element = @svg.select('g.elements')
            .selectAll('g.element')
            .data(diagram.elements)

        # Update

        # Enter
        element_g = @element.enter()
            .append('g')
            .attr('class', 'element')
            .call(@drag)
            .on("mousedown", (elt) ->
                return if d3.event.ctrlKey
                selected = d3.select(@).classed 'selected'
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
            .on("mouseup", (elt) =>
                return if d3.event.ctrlKey
                if state.linking.length
                    for lnk in state.linking
                        if lnk.source != elt
                            diagram.links.push(new Arrow(lnk.source, elt))
                    state.linking = []
                    @sync()
                    d3.event.preventDefault())
            .on('dblclick', (elt) ->
                return if d3.event.ctrlKey
                edit((-> elt.text), ((txt) -> elt.text = txt)))

        element_g
            .append('path')
            .attr('class', 'shape')

        element_g
            .append('text')

        # Update + Enter
        @element
            .select('text')
            .each((elt) ->
                txt = d3.select @
                return if elt.text == txt.text
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

        @link
            .select('path')
            .attr('d', (lnk) -> lnk.path())

        @link
            .select('text.start')
            .each((lnk) ->
                txt = d3.select @
                return if lnk.text.source == txt.text
                txt.selectAll('tspan').remove()
                for line, i in lnk.text.source.split('\n')
                    tspan = txt.append('tspan')
                        .text(line)
                        .attr('x', 0)
                    if i != 0
                        tspan
                            .attr('dy', '1.2em'))

        @link
            .select('text.end')
            .each((lnk) ->
                txt = d3.select @
                return if not lnk.text.target == txt.text
                txt.selectAll('tspan').remove()
                for line, i in lnk.text.target.split('\n')
                    tspan = txt.append('tspan')
                        .text(line)
                        .attr('x', 0)
                    if i != 0
                        tspan
                            .attr('dy', '1.2em'))

        @element
            .select('path.shape')
            .attr('d', (elt) -> elt.path())

        # Exit
        @element.exit()
            .remove()

        @link.exit()
            .remove()

        @tick()

        @force.start()


    tick: =>
        need_force = false

        for elt in diagram.elements
            if not elt.fixed
                need_force = true
                break

        need_force = need_force and (state.freemode or (@force.alpha() or 1) > .03)

        if not need_force and not state.dragging
            @force.stop()

        @element
            .attr("transform", ((elt) -> "translate(" + elt.x + "," + elt.y + ")"))
            .each((elt) -> d3.select(this).classed('moving', not elt.fixed))

        @link
            .select('path')
            .attr("d", (lnk) -> lnk.path())

        @link
            .select('text.start')
            .attr('transform', (lnk) -> "translate(#{lnk.a1.x}, #{lnk.a1.y})")
            .attr('dx', (lnk) ->
                if lnk.d1 in ['N', 'E']
                    lnk.text_margin + @getBBox().width / 2
                else
                    - (lnk.text_margin + @getBBox().width / 2))
            .attr('dy', (lnk) ->
                if lnk.d1 in ['N', 'E']
                     - (@getBBox().height + lnk.text_margin)
                else
                    lnk.text_margin)

        @link
            .select('text.end')
            .attr('transform', (lnk) -> "translate(#{lnk.a2.x}, #{lnk.a2.y})")
            .attr('dx', (lnk) ->
                if lnk.d2 in ['N', 'E']
                    lnk.text_margin + @getBBox().width / 2
                else
                    - (lnk.text_margin + @getBBox().width / 2))
            .attr('dy', (lnk) ->
                if lnk.d2 in ['N', 'E']
                     - (@getBBox().height + lnk.text_margin)
                else
                    lnk.text_margin)

    resize: ->
        @width = @article.node().clientWidth
        @height = @article.node().clientHeight or 500
        @svg
            .attr("width", @width)
            .attr("height", @height)
        @underlay
            .attr("width", @width)
            .attr("height", @height)

