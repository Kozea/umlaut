# This file is part of umlaut

# Copyright (C) 2013 Kozea - Mounier Florian <paradoxxx.zero->gmail.com>

# umlaut is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or any later version.

# umlaut is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.


move_drag = d3.behavior.drag()
    .origin((i) -> i)
    .on('dragstart', (node) ->
        return if d3.event.sourceEvent.which is not 1 or d3.event.sourceEvent.ctrlKey
        svg.svg.classed('dragging', true)
        svg.svg.classed('translating', true)

        diagram.dragging = true
    ).on("drag", (node) ->
        return if not diagram.dragging or d3.event.sourceEvent.ctrlKey
        x = if diagram.force then 'px' else 'x'
        y = if diagram.force then 'py' else 'y'

        if not node in diagram.selection
            diagram.selection.push node

        for nod in diagram.selection
            nod.fixed = true

        if d3.event.sourceEvent.shiftKey
            delta =
                x: node[x] - d3.event.x
                y: node[y] - d3.event.y
        else
            delta =
                x: node[x] - diagram.snap.x * Math.floor(d3.event.x / diagram.snap.x)
                y: node[y] - diagram.snap.y * Math.floor(d3.event.y / diagram.snap.y)

        for nod in diagram.selection
            nod[x] -= delta.x
            nod[y] -= delta.y

        if diagram.force
            diagram.force.resume()
        else
            svg.tick()
    ).on('dragend', (node) ->
        svg.svg.classed('dragging', false)
        svg.svg.classed('translating', false)
        return if not diagram.dragging
        for node in diagram.nodes()
            node.fixed = false

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
        svg.sync(true))

nsweo_resize_drag = d3.behavior.drag()
    .on("dragstart", (handle) ->
        return if d3.event.sourceEvent.ctrlKey
        svg.svg.classed('dragging', true)
        svg.svg.classed('resizing', true)
        node = d3.select($(@).closest('.node').get(0)).data()[0]
        diagram._origin = mouse_xy svg.svg.node()
        node.ox = node.x
        node.oy = node.y
        node.owidth = node.width()
        node.oheight = node.height()
        node.fixed = true
        d3.event.sourceEvent.stopPropagation()
    ).on("drag", (handle) ->
        return if d3.event.ctrlKey
        nodes = d3.select($(@).closest('.node').get(0))
        node = nodes.data()[0]
        m = mouse_xy svg.svg.node()
        if handle is 'O'
            delta =
                x: m.x - node.x
                y: m.y - node.y

            angle = atan2(delta.y, delta.x) + pi / 2  # Mouse is above

            if not d3.event.sourceEvent.shiftKey
                angle = to_rad(diagram.snap.a * Math.floor(to_deg(angle) / diagram.snap.a))

            node._rotation = angle
        else
            delta =
                x: m.x - diagram._origin.x
                y: m.y - diagram._origin.y
            delta = rotate delta, 2 * pi - node._rotation
            x = if diagram.force then 'px' else 'x'
            y = if diagram.force then 'py' else 'y'

            signs = cardinal_to_direction handle
            node.width(node.owidth + signs.x * delta.x)
            node.height(node.oheight + signs.y * delta.y)
            shift =
                x: signs.x * (node.width() - node.owidth) / 2
                y: signs.y * (node.height() - node.oheight) / 2
            shift = rotate shift, node._rotation
            node[x] = node.ox + shift.x
            node[y] = node.oy + shift.y

            nodes.call(update_node)
        svg.tick()
    ).on("dragend", (handle) ->
        return if d3.event.ctrlKey
        svg.svg.classed('dragging', false)
        svg.svg.classed('resizing', false)
        node = d3.select($(@).closest('.node').get(0)).data()[0]
        node.ox = node.oy = node.owidth = node.oheight = null
        node.fixed = false
        svg.sync(true))

anchor_link_drag = d3.behavior.drag()
    .on("dragstart", (anchor) ->
        return if d3.event.sourceEvent.ctrlKey
        svg.svg.classed('dragging', true)
        svg.svg.classed('linking', true)
        node = d3.select($(@).closest('.node').get(0)).data()[0]
        type = diagram.last_types.link
        link = new type(node, diagram.mouse)
        link.source_anchor = anchor
        diagram.linking.push(link)
        svg.sync(true)
        d3.event.sourceEvent.stopPropagation()
    ).on("drag", (anchor) ->
        return if d3.event.ctrlKey
        node = d3.select($(@).closest('.node').get(0)).data()[0]
        svg.tick()
    ).on("dragend", (anchor) ->
        return if d3.event.ctrlKey
        svg.svg.classed('dragging', false)
        svg.svg.classed('linking', false)
        node = d3.select($(@).closest('.node').get(0)).data()[0]
        diagram.linking = []
        svg.sync(true))


mouse_anchor = (anchor) ->
    anchor
        .on("mousemove", (anchor) ->
            return if d3.event.ctrlKey
            d3.select(@).classed('active', true)
            node = d3.select($(@).closest('.node').get(0)).data()[0]
            for lnk in diagram.linking
                if lnk._drag and lnk._drag == 'source'
                    lnk.source_anchor = anchor
                    lnk.source = node
                else
                    lnk.target_anchor = anchor
                    lnk.target = node)
        .on("mouseout", (anchor) ->
            return if d3.event.ctrlKey
            d3.select(@).classed('active', false)
            for lnk in diagram.linking
                if lnk._drag and lnk._drag == 'source'
                    lnk.source_anchor = null
                    lnk.source = diagram.mouse
                else
                    lnk.target_anchor = null
                    lnk.target = diagram.mouse)
        .on("mouseup", (anchor) =>
            return if d3.event.ctrlKey
            node = d3.select($(@).closest('.node').get(0)).data()[0]
            if diagram.linking.length
                for lnk in diagram.linking
                    if diagram.mouse not in [lnk.source, lnk.target]
                        diagram.links.push(lnk)
                diagram.linking = []
                svg.sync(true)
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
            node.ts = timestamp()
            svg.svg.selectAll('g.node').sort(order)
            svg.svg.selectAll('g.element')
                .each((elt) ->
                    if elt not in diagram.selection and node.contains elt
                        diagram.selection.push elt)
            svg.tick())
        .on("mousemove", (node) ->
            return if d3.event.ctrlKey
            for lnk in diagram.linking
                if lnk._drag and lnk._drag == 'source'
                    lnk.source = node
                else
                    lnk.target = node)
        .on("mouseout", (node) ->
            return if d3.event.ctrlKey
            for lnk in diagram.linking
                if lnk._drag and lnk._drag == 'source'
                    lnk.source = diagram.mouse
                else
                    lnk.target = diagram.mouse)
        .on("mouseup", (node) =>
            return if d3.event.ctrlKey
            if diagram.linking.length
                for lnk in diagram.linking
                    if diagram.mouse not in [lnk.source, lnk.target]
                        diagram.links.push(lnk)
                diagram.linking = []
                svg.sync(true)
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
        return if d3.event.sourceEvent.ctrlKey
        if not d3.event.sourceEvent.shiftKey and Math.min(dist(diagram.mouse, link.a1), dist(diagram.mouse, link.a2)) > 20
            return
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
        svg.sync(true))
