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
                    x: node.px - diagram.snap.x * Math.floor(d3.event.x / diagram.snap.x)
                    y: node.py - diagram.snap.y * Math.floor(d3.event.y / diagram.snap.y)

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

nsweo_resize_drag = d3.behavior.drag()
    .on("dragstart", (handle) ->
        node = d3.select($(@).closest('.element,.group').get(0)).data()[0]
        diagram._origin = mouse_xy svg.svg.node()
        node.px = node.x
        node.py = node.y
        node.pwidth = node.width()
        node.pheight = node.height()
        d3.event.sourceEvent.stopPropagation()
    ).on("drag", (handle) ->
        nodes = d3.select($(@).closest('.element,.group').get(0))
        node = nodes.data()[0]
        m = mouse_xy svg.svg.node()
        if handle is 'O'
            delta =
                x: m.x - node.x
                y: m.y - node.y

            if delta.x != 0
                angle = 90 + 180 * (Math.atan(delta.y / delta.x)) / Math.PI
            else
                angle = 0
            if delta.x < 0
                angle += 180
            if not d3.event.sourceEvent.shiftKey
                angle = diagram.snap.a * Math.floor(angle / diagram.snap.a)

            node._rotation = angle
        else
            delta =
                x: m.x - diagram._origin.x
                y: m.y - diagram._origin.y
            switch handle
                when 'SE'
                    signs =
                        x: 1
                        y: 1
                when 'SW'
                    signs =
                        x: -1
                        y: 1
                when 'NW'
                    signs =
                        x: -1
                        y: -1
                when 'NE'
                    signs =
                        x: 1
                        y: -1

            node.width(node.pwidth + signs.x * delta.x)
            node.height(node.pheight + signs.y * delta.y)
            node.x = node.px + signs.x * (node.width() - node.pwidth) / 2
            node.y = node.py + signs.y * (node.height() - node.pheight) / 2

            nodes.select('.shape').attr('d', node.path())
            nodes.select('.ghost').attr('d', Rect::path.apply(node))
            nodes
                .select('text')
                .attr('x', node.txt_x())
                .attr('y', node.txt_y())
                .selectAll('tspan')
                .attr('x', node.txt_x())
        svg.tick()
    ).on("dragend", (handle) ->
        node = d3.select($(@).closest('.element,.group').get(0)).data()[0]
        node.px = node.x
        node.py = node.y
        node.pwidth = node.pheight = null
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
