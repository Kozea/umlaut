mouse_xy = (e) ->
    m = d3.mouse(e)

    x: (m[0] - diagram.zoom.translate[0]) / diagram.zoom.scale
    y: (m[1] - diagram.zoom.translate[1]) / diagram.zoom.scale


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
            .attr('id', "diagram")
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
            .attr('width', diagram.snap)
            .attr('height', diagram.snap)
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
                return if not diagram.dragging or d3.event.sourceEvent.ctrlKey

                if not elt in diagram.selection
                    diagram.selection.push elt

                if d3.event.sourceEvent.shiftKey
                    delta =
                        x: elt.px - d3.event.x
                        y: elt.py - d3.event.y
                else
                    delta =
                        x: elt.px - diagram.snap * Math.floor(d3.event.x / diagram.snap)
                        y: elt.py - diagram.snap * Math.floor(d3.event.y / diagram.snap)

                for elt in diagram.selection
                    elt.px -= delta.x
                    elt.py -= delta.y

                @force.resume()
            ).on('dragstart', ->
                return if d3.event.sourceEvent.which is 3 or d3.event.sourceEvent.ctrlKey
                diagram.dragging = true
            ).on('dragend', (elt) =>
                if not $(d3.event.sourceEvent.target).closest('#diagram').size()
                    diagram.elements.splice(diagram.elements.indexOf(elt), 1)
                    if elt in diagram.selection
                        diagram.selection.splice(diagram.selection.indexOf(elt), 1)
                    for lnk in diagram.links.slice()
                        if elt == lnk.source or elt == lnk.target
                            diagram.links.splice(diagram.links.indexOf(lnk), 1)
                    svg.sync()
                diagram.dragging = false
                if not diagram.freemode
                    elt.fixed = true
            )

        @element = null
        @link = null

        @svg.on("mousedown", (event) =>
            return if diagram.dragging or d3.event.ctrlKey or d3.event.which is 2

            if d3.event.which is 3
                diagram.linking = []
                for elt in diagram.selection
                     diagram.linking.push(new Arrow(elt, diagram.mouse))
                @sync()
            else
                if not d3.event.shiftKey
                    d3.selectAll('.selected').classed('selected', false)
                    diagram.selection = []

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
            diagram.mouse.x = mouse.x
            diagram.mouse.y = mouse.y
            if diagram.linking.length
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

                rect.width = Math.max(0, rect.width)
                rect.height = Math.max(0, rect.height)

                sel.attr rect
                d3.selectAll('g.element').each((elt) ->
                    g = d3.select @
                    selected = g.classed 'selected'
                    if elt.in(rect) and not selected
                        diagram.selection.push(elt)
                        g.classed 'selected', true
                    else if not elt.in(rect) and selected and not d3.event.shiftKey
                        diagram.selection.splice(diagram.selection.indexOf(elt), 1)
                        g.classed 'selected', false
                )
                d3.event.preventDefault()

        ).on("mouseup", =>
            return if d3.event.ctrlKey
            if diagram.linking.length
                diagram.linking = []
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
            .scale(diagram.zoom.scale)
            .translate(diagram.zoom.translate)
            .scaleExtent([.15, 5])
            .on("zoom", =>
                if not d3.event.sourceEvent or d3.event.sourceEvent.type in ['wheel', 'click'] or d3.event.sourceEvent.ctrlKey or d3.event.sourceEvent.which is 2
                    diagram.zoom.translate = d3.event.translate
                    diagram.zoom.scale = d3.event.scale
                    @root.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
                    @pattern.attr("patternTransform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
                else
                    @zoom.scale(diagram.zoom.scale)
                    @zoom.translate(diagram.zoom.translate)
            )
        @root.attr("transform", "translate(" + diagram.zoom.translate + ")scale(" + diagram.zoom.scale + ")")
        @pattern.attr("patternTransform", "translate(" + diagram.zoom.translate + ")scale(" + diagram.zoom.scale + ")")
        @underlay_g.call(@zoom)

        @force
            .on('tick', @tick)
            .on('end', =>
                if not diagram.freemode
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
            .data(diagram.links.concat(diagram.linking))

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
                nearest = lnk.nearest diagram.mouse
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
                if (selected and not diagram.dragging) or (not selected) and not d3.event.shiftKey
                    d3.selectAll('.selected').classed('selected', false)
                    diagram.selection = [elt]
                    d3.select(this).classed('selected', true)

                if d3.event.shiftKey and not selected
                    d3.select(this).classed('selected', true)
                    diagram.selection.push(elt))
            .on("mousemove", (elt) ->
                return if d3.event.ctrlKey
                for lnk in diagram.linking
                    lnk.target = elt)
            .on("mouseout", (elt) ->
                return if d3.event.ctrlKey
                for lnk in diagram.linking
                    lnk.target = diagram.mouse)
            .on("mouseup", (elt) =>
                return if d3.event.ctrlKey
                if diagram.linking.length
                    for lnk in diagram.linking
                        if lnk.source != elt
                            diagram.links.push(new Arrow(lnk.source, elt))
                    diagram.linking = []
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
            .each((elt) -> elt.set_txt_bbox(@getBBox()))
            .attr('x', (elt) -> elt.txt_x())
            .attr('y', (elt) -> elt.txt_y())

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

        need_force = need_force and (diagram.freemode or (@force.alpha() or 1) > .03)

        if not need_force and not diagram.dragging
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

