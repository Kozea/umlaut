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

        @zoom = d3.behavior.zoom()
            .scale(diagram.zoom.scale)
            .translate(diagram.zoom.translate)
            .scaleExtent([.15, 5])
            .on("zoom", =>
                if not d3.event.sourceEvent or d3.event.sourceEvent.type in ['wheel', 'click'] or d3.event.sourceEvent.ctrlKey or d3.event.sourceEvent.which is 2
                    diagram.zoom.translate = d3.event.translate
                    diagram.zoom.scale = d3.event.scale
                    d3.select('.root').attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
                    d3.select('#grid').attr("patternTransform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")")
                else
                    @zoom.scale(diagram.zoom.scale)
                    @zoom.translate(diagram.zoom.translate)
            )

        @article
            .selectAll('svg')
            .data([diagram])
            .enter()
                .append("svg")
                .attr('id', "diagram")
                .attr("width", @width)
                .attr("height", @height)
                .call(@create)

        @svg = d3.select('#diagram')

        markers = @svg.select('defs')
            .selectAll('marker')
            .data(diagram.markers())

        markers
            .enter()
                .append('marker')
                .attr('id', (m) -> m.id)
                .attr('viewBox', '-10 -10 30 30')
                .attr('refX', 20)
                .attr('refY', 5)
                .attr('markerUnits', 'userSpaceOnUse')
                .attr('markerWidth', 40)
                .attr('markerHeight', 40)
                .attr('orient', 'auto')
                .append('path')
                    .attr('d', (m) -> m.path())
        markers
            .exit()
            .remove()

        @force = d3.layout.force()
            .gravity(.2)
            .linkDistance(100)
            .charge(-5000)
            .size([@width, @height])

        @svg.on("mousedown", (event) =>
            return if diagram.dragging or d3.event.ctrlKey or d3.event.which is 2
            if d3.event.altKey and d3.event.shiftKey
                diagram.groupping = true
            if d3.event.which is 3
                diagram.linking = []
                for elt in diagram.selection
                     diagram.linking.push(new diagram.types.links[0](elt, diagram.mouse))
                @sync()
            else
                if not d3.event.shiftKey
                    diagram.selection = []
                    svg.tick()

                mouse = mouse_xy(@svg.node())
                @svg.select(if diagram.groupping then 'g.underlay' else 'g.overlay')
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

                @svg.selectAll('g.element,g.group').each((elt) ->
                    g = d3.select @
                    selected = elt in diagram.selection
                    if elt.in(rect) and not selected
                        diagram.selection.push(elt)
                    else if not elt.in(rect) and selected and not d3.event.shiftKey
                        diagram.selection.splice(diagram.selection.indexOf(elt), 1)
                )
                svg.tick()
                d3.event.preventDefault()

        ).on("mouseup", =>
            return if d3.event.ctrlKey
            if diagram.linking.length
                diagram.linking = []
                @sync()
            if diagram.groupping
                sel = @svg.select("rect.selection")
                x = + sel.attr("x")
                y = + sel.attr("y")
                width = + sel.attr("width")
                height = + sel.attr("height")
                type = diagram.types.groups[0]
                nth = diagram.groups.filter((grp) -> grp instanceof type).length + 1
                grp = new type(x + width / 2, y + height / 2, "#{type.name} ##{nth}", not diagram.freemode)
                grp._width = width
                grp._height = height
                diagram.groups.push grp
                diagram.groupping = false
                @sync()

            @svg.selectAll("rect.selection").remove()
            d3.event.preventDefault()
        ).on("keydown", =>
            if d3.event.ctrlKey
                d3.select('.background').classed('move', true)
        ).on("keyup", =>
            d3.select('.background').classed('move', false)
        )

        @force
            .on('tick', => @tick())
            .on('end', =>
                if not diagram.freemode
                    for elt in diagram.nodes()
                        elt.fixed = true
                # Last adjustements
                @tick()
                generate_url()
            )

    create: (svg) =>
        defs = svg
            .append('defs')

        background_g = svg
            .append('g')
            .attr('id', 'bg')

        background = background_g
            .append('rect')
            .attr('class', 'background')
            .attr('width', @width)
            .attr('height', @height)
            .attr('fill', 'url(#grid)')
            .call(@zoom)

        d3.select(window).on('resize', => @resize())

        pattern = defs
            .append('pattern')
            .attr('id', 'grid')
            .attr('viewBox', '0 0 10 10')
            .attr('x', 0)
            .attr('y', 0)
            .attr('width', diagram.snap)
            .attr('height', diagram.snap)
            .attr('patternUnits', 'userSpaceOnUse')

        pattern
            .append('path')
            .attr('d', 'M 10 0 L 0 0 L 0 10')

        root = background_g
            .append('g')
            .attr('class', 'root')

        root
            .append('g')
            .attr('class', 'underlay')

        root
            .append('g')
            .attr('class', 'groups')

        root
            .append('g')
            .attr('class', 'links')

        root
            .append('g')
            .attr('class', 'elements')

        root
            .append('g')
            .attr('class', 'overlay')


    sync: ->
        @zoom.scale(diagram.zoom.scale)
        @zoom.translate(diagram.zoom.translate)
        @zoom.event(d3.select('#bg'))
        @title.text(diagram.title)
        force_drag = @force.drag()
            .on("drag.force", (elt) ->
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

                svg.force.resume()
            ).on('dragstart', ->
                return if d3.event.sourceEvent.which is 3 or d3.event.sourceEvent.ctrlKey
                diagram.dragging = true
            ).on('dragend', (elt) =>
                return if not diagram.dragging
                diagram.dragging = false
                if not $(d3.event.sourceEvent.target).closest('.inside').size()
                    if elt in diagram.elements
                        diagram.elements.splice(diagram.elements.indexOf(elt), 1)
                    if elt in diagram.groups
                        diagram.groups.splice(diagram.groups.indexOf(elt), 1)
                    if elt in diagram.selection
                        diagram.selection.splice(diagram.selection.indexOf(elt), 1)
                    for lnk in diagram.links.slice()
                        if elt == lnk.source or elt == lnk.target
                            diagram.links.splice(diagram.links.indexOf(lnk), 1)
                    svg.sync()
                if not diagram.freemode
                    elt.fixed = true
            )

        @force.nodes(diagram.nodes())
            .links(diagram.links)

        group = @svg.select('g.groups').selectAll('g.group')
            .data(diagram.groups)

        group_g = group.enter()
            .append('g')
            .attr("class", "group")
            .call(force_drag)
            .on("mousedown", (grp) ->
                return if d3.event.ctrlKey

                selected = grp in diagram.selection
                if (selected and not diagram.dragging) or (not selected) and not d3.event.shiftKey
                    diagram.selection = [grp]
                if d3.event.shiftKey and not selected
                    diagram.selection.push(grp)
                if d3.event.which != 3
                    svg.svg.selectAll('g.element')
                        .each((elt) ->
                            if elt not in diagram.selection and grp.contains elt
                                diagram.selection.push elt)
                svg.tick())
            .on("mousemove", (grp) ->
                return if d3.event.ctrlKey
                for lnk in diagram.linking
                    lnk.target = grp)
            .on("mouseout", (grp) ->
                return if d3.event.ctrlKey
                for lnk in diagram.linking
                    lnk.target = diagram.mouse)
            .on("mouseup", (grp) =>
                return if d3.event.ctrlKey
                if diagram.linking.length
                    for lnk in diagram.linking
                        if lnk.source != grp
                            diagram.links.push(new lnk.constructor(lnk.source, grp))
                    diagram.linking = []
                    @sync()
                    d3.event.preventDefault())
            .on('dblclick', (grp) ->
                return if d3.event.ctrlKey
                edit((-> grp.text), ((txt) -> grp.text = txt)))

        resize_drag = d3.behavior.drag()
            .on("dragstart", (grp) ->
                d3.event.sourceEvent.stopPropagation())
            .on("drag", (grp) ->
                grp._width += d3.event.dx * 2
                grp._height += d3.event.dy * 2

                group = d3.select(@parentNode)
                group
                    .selectAll('path')
                    .attr('d', grp.path())
                group
                    .select('text')
                    .attr('x', grp.txt_x())
                    .attr('y', grp.txt_y())
                    .selectAll('tspan')
                    .attr('x', grp.txt_x())
                svg.tick())

            .on("dragend", (grp) ->
                grp._width = grp.width()
                grp._height = grp.height()
                generate_url())

        group_g
            .append('path')
            .attr('class', 'ghost')
            .call(resize_drag)

        group_g
            .append('path')
            .attr('class', 'shape')

        group_g
            .append('text')

        group
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
            .selectAll('tspan')
            .attr('x', (elt) -> elt.txt_x())

        group
            .each((grp) ->
                $(@).find('path').attr('d', grp.path()))

        link = @svg.select('g.links').selectAll('g.link')
            .data(diagram.links.concat(diagram.linking))

        link_g = link.enter()
            .append('g')
            .attr("class", "link")

        link_g
            .append("path")
            .attr('class', (lnk) -> "shape #{lnk.constructor.type}")
            .attr("marker-end", (lnk) -> "url(##{lnk.constructor.marker.id})")

        link_g
            .append("path")
            .attr('class', 'ghost')

        link_g
            .append("text")
            .attr('class', "start")

        link_g
            .append("text")
            .attr('class', "end")

        link_g
            .on('mousedown', (lnk) ->
                if not d3.event.shiftKey
                    diagram.selection = []
                diagram.selection.push(lnk)
                svg.tick()
                d3.event.stopPropagation())
            .on('dblclick', (lnk) ->
                return if d3.event.ctrlKey
                nearest = lnk.nearest diagram.mouse
                if nearest is lnk.source
                    edit((-> lnk.text.source), ((txt) -> lnk.text.source = txt))
                else
                    edit((-> lnk.text.target), ((txt) -> lnk.text.target = txt)))

        element = @svg.select('g.elements').selectAll('g.element')
            .data(diagram.elements)

        # Update

        # Enter
        element_g = element.enter()
            .append('g')
            .attr('class', 'element')
            .call(force_drag)
            .on("mousedown", (elt) ->
                return if d3.event.ctrlKey
                selected = elt in diagram.selection
                if (selected and not diagram.dragging) or (not selected) and not d3.event.shiftKey
                    diagram.selection = [elt]
                if d3.event.shiftKey and not selected
                    diagram.selection.push(elt)
                svg.tick())
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
                            diagram.links.push(new lnk.constructor(lnk.source, elt))
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
            .append('path')
            .attr('class', 'ghost')

        element_g
            .append('text')

        # Update + Enter
        element
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
            .selectAll('tspan')
                .attr('x', (elt) -> elt.txt_x())

        link
            .each((lnk) ->
                $(@).find('path').attr('d', lnk.path()))

        link
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

        link
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

        element
            .each((elt) ->
                $(@).find('path').attr('d', elt.path()))

        # Exit
        group.exit()
            .remove()

        element.exit()
            .remove()

        link.exit()
            .remove()

        @tick()

        @force.start()

    tick: ->
        need_force = false
        for elt in diagram.nodes()
            if not elt.fixed
                need_force = true
                break

        need_force = need_force and (diagram.freemode or (@force.alpha() or 1) > .03)

        if not need_force and not diagram.dragging
            @force.stop()

        @svg.select('g.groups').selectAll('g.group')
            .attr("transform", ((grp) -> "translate(" + grp.x + "," + grp.y + ")"))
            .classed('moving', (grp) -> not grp.fixed)
            .classed('selected', (grp) -> grp in diagram.selection)

        @svg.select('g.elements').selectAll('g.element')
            .attr("transform", ((elt) -> "translate(" + elt.x + "," + elt.y + ")"))
            .classed('moving', (elt) -> not elt.fixed)
            .classed('selected', (elt) -> elt in diagram.selection)

        link = @svg.select('g.links').selectAll('g.link')
            .classed('selected', (lnk) -> lnk in diagram.selection)

        link
            .each((lnk) ->
                $(@).find('path').attr('d', lnk.path()))

        link
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

        link
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
        d3.select('.background')
            .attr("width", @width)
            .attr("height", @height)
