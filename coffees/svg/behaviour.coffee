force_drag = (force) ->
    force
        .on('dragstart', (node) ->
            svg.svg.classed('dragging', true)
            svg.svg.classed('translating', true)
            return if d3.event.sourceEvent.which is 3 or d3.event.sourceEvent.ctrlKey

            diagram.dragging = true
        ).on("drag.force", (node) ->
            return if not diagram.dragging or d3.event.sourceEvent.ctrlKey

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
        ).on('dragend', (node) ->
            svg.svg.classed('dragging', false)
            svg.svg.classed('translating', false)
            return if not diagram.dragging
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
        return if d3.event.ctrlKey
        svg.svg.classed('dragging', true)
        svg.svg.classed('resizing', true)
        node = d3.select($(@).closest('.element,.group').get(0)).data()[0]
        diagram._origin = mouse_xy svg.svg.node()
        node.px = node.x
        node.py = node.y
        node.pwidth = node.width()
        node.pheight = node.height()
        d3.event.sourceEvent.stopPropagation()
    ).on("drag", (handle) ->
        return if d3.event.ctrlKey
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
            delta = rotate delta, 360 - node._rotation


            signs = cardinal_to_direction handle
            node.width(node.pwidth + signs.x * delta.x)
            node.height(node.pheight + signs.y * delta.y)
            shift =
                x: signs.x * (node.width() - node.pwidth) / 2
                y: signs.y * (node.height() - node.pheight) / 2
            shift = rotate shift, node._rotation
            node.x = node.px + shift.x
            node.y = node.py + shift.y

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
        return if d3.event.ctrlKey
        svg.svg.classed('dragging', false)
        svg.svg.classed('resizing', false)
        node = d3.select($(@).closest('.element,.group').get(0)).data()[0]
        node.px = node.x
        node.py = node.y
        node.pwidth = node.pheight = null
        generate_url())

anchor_link_drag = d3.behavior.drag()
    .on("dragstart", (anchor) ->
        return if d3.event.ctrlKey
        svg.svg.classed('dragging', true)
        svg.svg.classed('linking', true)
        node = d3.select($(@).closest('.element,.group').get(0)).data()[0]
        type = diagram.last_types.link or diagram.types.links[0]
        link = new type(node, diagram.mouse)
        link.source_anchor = anchor
        diagram.linking.push(link)
        svg.sync()
        d3.event.sourceEvent.stopPropagation()
    ).on("drag", (anchor) ->
        return if d3.event.ctrlKey
        node = d3.select($(@).closest('.element,.group').get(0)).data()[0]
        svg.tick()
    ).on("dragend", (anchor) ->
        return if d3.event.ctrlKey
        svg.svg.classed('dragging', false)
        svg.svg.classed('linking', false)
        node = d3.select($(@).closest('.element,.group').get(0)).data()[0]
        diagram.linking = []
        svg.sync())


mouse_anchor = (anchor) ->
    anchor
        .on("mousemove", (anchor) ->
            return if d3.event.ctrlKey
            d3.select(@).classed('active', true)
            node = d3.select($(@).closest('.element,.group').get(0)).data()[0]
            for lnk in diagram.linking
                if lnk._drag == 'source'
                    lnk.source_anchor = anchor
                    lnk.source = node
                else
                    lnk.target_anchor = anchor
                    lnk.target = node)
        .on("mouseout", (anchor) ->
            return if d3.event.ctrlKey
            d3.select(@).classed('active', false)
            for lnk in diagram.linking
                if lnk._drag == 'source'
                    lnk.source_anchor = null
                    lnk.source = diagram.mouse
                else
                    lnk.target_anchor = null
                    lnk.target = diagram.mouse)
        .on("mouseup", (anchor) =>
            return if d3.event.ctrlKey
            node = d3.select($(@).closest('.element,.group').get(0)).data()[0]
            if diagram.linking.length
                for lnk in diagram.linking
                    if lnk.source != lnk.target
                        diagram.links.push(lnk)
                diagram.linking = []
                svg.sync()
                d3.event.preventDefault())

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
                if node instanceof Group
                    i = diagram.groups.indexOf(node)
                    if i >= 0 and i != diagram.groups.length
                        diagram.groups.splice(i, 1)
                        diagram.groups.push(node)
                        svg.sync()
                else
                    i = diagram.elements.indexOf(node)
                    if i >= 0 and i != diagram.elements.length
                        diagram.elements.splice(diagram.elements.indexOf(node), 1)
                        diagram.elements.push(node)
                        svg.sync()
                svg.svg.selectAll('g.element')
                    .each((elt) ->
                        if elt not in diagram.selection and node.contains elt
                            diagram.selection.push elt)
            svg.tick())
        .on("mousemove", (node) ->
            return if d3.event.ctrlKey
            for lnk in diagram.linking
                if lnk._drag == 'source'
                    lnk.source = node
                else
                    lnk.target = node)
        .on("mouseout", (node) ->
            return if d3.event.ctrlKey
            for lnk in diagram.linking
                if lnk._drag == 'source'
                    lnk.source = diagram.mouse
                else
                    lnk.target = diagram.mouse)
        .on("mouseup", (node) =>
            return if d3.event.ctrlKey
            if diagram.linking.length
                for lnk in diagram.linking
                    if lnk.source != lnk.target
                        diagram.links.push(lnk)
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

link_drag = d3.behavior.drag()
    .on("dragstart", (link) ->
        return if d3.event.ctrlKey
        svg.svg.classed('dragging', true)
        svg.svg.classed('linking', true)

        diagram.links.splice(diagram.links.indexOf(link), 1)

        nearest = link.nearest diagram.mouse
        if link.source == nearest
            link.source = diagram.mouse
            link.source_anchor = null
            link._drag = 'source'
        else
            link.target = diagram.mouse
            link.target_anchor = null
            link._drag = 'target'

        diagram.linking.push(link)
        svg.sync()
        d3.event.sourceEvent.stopPropagation()
    ).on("drag", (anchor) ->
        return if d3.event.ctrlKey
        svg.tick()
    ).on("dragend", (anchor) ->
        return if d3.event.ctrlKey
        svg.svg.classed('dragging', false)
        svg.svg.classed('linking', false)
        diagram.linking = []
        svg.sync())
