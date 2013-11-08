force_drag = (force) ->
    force
        .on("drag.force", (node) ->
            return if not diagram.dragging or d3.event.sourceEvent.ctrlKey or (d3.event.sourceEvent.which is 2 and node.cls.rotationable)

            if not node in diagram.selection
                diagram.selection.push node

            if d3.event.sourceEvent.shiftKey
                delta =
                    x: node.px - d3.event.x
                    y: node.py - d3.event.y
            else
                delta =
                    x: node.px - diagram.snap * Math.floor(d3.event.x / diagram.snap)
                    y: node.py - diagram.snap * Math.floor(d3.event.y / diagram.snap)

            for node in diagram.selection
                node.px -= delta.x
                node.py -= delta.y

            svg.force.resume()
        ).on('dragstart', (node) ->
            return if d3.event.sourceEvent.which is 3 or d3.event.sourceEvent.ctrlKey or (d3.event.sourceEvent.which is 2 and node.cls.rotationable) or (d3.event.sourceEvent.which is 1 and node.cls.resizeable and d3.select(d3.event.sourceEvent.target).classed('ghost'))

            diagram.dragging = true
        ).on('dragend', (node) ->
            return if not diagram.dragging or (d3.event.sourceEvent.which is 2 and node.cls.rotationable)
            diagram.dragging = false
            if not $(d3.event.sourceEvent.target).closest('.inside').size()
                if node in diagram.elements
                    diagram.elements.splice(diagram.elements.indexOf(node), 1)
                if node in diagram.groups
                    diagram.groups.splice(diagram.groups.indexOf(node), 1)
                if node in diagram.selection
                    diagram.selection.splice(diagram.selection.indexOf(node), 1)
                for lnk in diagram.links.slice()
                    if node == lnk.source or node == lnk.target
                        diagram.links.splice(diagram.links.indexOf(lnk), 1)
                svg.sync()
            if not diagram.freemode
                node.fixed = true)

ghost_drag = d3.behavior.drag()
    .on("dragstart", (node) ->
        if node.cls.resizeable and d3.event.sourceEvent.which is 1
            ghost_drag.resize = true
            d3.event.sourceEvent.stopPropagation()
        if node.cls.rotationable and d3.event.sourceEvent.which is 2
            ghost_drag.rotate = true
            d3.event.sourceEvent.stopPropagation()
    ).on("drag", (node) ->
        if ghost_drag.resize
            group = d3.select(@parentNode)
            node.width(node.width() + d3.event.dx * 2)
            node.height(node.height() + d3.event.dy * 2)

            group
                .selectAll('path')
                .attr('d', node.path())
            group
                .select('text')
                .attr('x', node.txt_x())
                .attr('y', node.txt_y())
                .selectAll('tspan')
                .attr('x', node.txt_x())
            svg.tick()
        if ghost_drag.rotate
            group = d3.select(@parentNode)
            rotations =
                E: 0
                S: 90
                W: 180
                N: 270

            mouse = mouse_xy d3.select('#diagram').node()
            direction = node.super('direction', Electric, [mouse.x, mouse.y])
            node._rotation = rotations[direction]
            svg.tick())
    .on("dragend", (node) ->
        return if not ghost_drag.resize and not ghost_drag.rotate
        ghost_drag.resize = ghost_drag.rotate = false
        generate_url())


mouse_node = (node) ->
    node
        .on("mousedown", (node) ->
            return if d3.event.ctrlKey
            selected = node in diagram.selection
            if (selected and not diagram.dragging) or (not selected) and not d3.event.shiftKey
                diagram.selection = [node]
            if d3.event.shiftKey and not selected
                diagram.selection.push(node)
            if d3.event.which != 3
                    svg.svg.selectAll('g.element')
                        .each((node) ->
                            if node not in diagram.selection and node.contains node
                                diagram.selection.push node)
            svg.tick())
        .on("mousemove", (node) ->
            return if d3.event.ctrlKey
            for lnk in diagram.linking
                lnk.target = node)
        .on("mouseout", (node) ->
            return if d3.event.ctrlKey
            for lnk in diagram.linking
                lnk.target = diagram.mouse)
        .on("mouseup", (node) =>
            return if d3.event.ctrlKey
            if diagram.linking.length
                for lnk in diagram.linking
                    if lnk.source != node
                        diagram.links.push(new lnk.cls(lnk.source, node))
                diagram.linking = []
                svg.sync()
                d3.event.preventDefault())
        .on('dblclick', (node) ->
            return if d3.event.ctrlKey
            edit((-> node.text), ((txt) -> node.text = txt)))

mouse_link = (link) ->
    link
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
