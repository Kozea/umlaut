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

svg_selection_drag = d3.behavior.drag()
    .on("dragstart.selection", ->
        if not d3.event.sourceEvent.shiftKey
            diagram.selection = []
            if diagram.linking.length
                # Something went wrong
                diagram.linking = []
                svg.sync()
            svg.tick()
            return

    ).on("drag.selection", ->
        if not d3.event.sourceEvent.shiftKey
            return

        sel = svg.svg.select('rect.selection')
        if sel.empty()
            sel = svg.svg.select('#bg')
                .append("rect").attr
                    class: "selection"
                    x: d3.event.x
                    y: d3.event.y
                    width: 0
                    height: 0

        rect =
            x: + sel.attr('x')
            y: + sel.attr('y')
            width: + sel.attr('width')
            height: + sel.attr('height')

        move =
            x: (d3.event.x - rect.x)
            y: (d3.event.y - rect.y)

        if move.x < 1 or (move.x * 2 < rect.width)
            rect.x = d3.event.x
            rect.width -= move.x
        else
            rect.width = move.x
        if move.y < 1 or (move.y * 2 < rect.height)
            rect.y = d3.event.y
            rect.height -= move.y
        else
            rect.height = move.y

        rect.width = Math.max(0, rect.width)
        rect.height = Math.max(0, rect.height)

        sel.attr rect

        svg.svg.selectAll('g.element').each((elt) ->
            g = d3.select @
            selected = elt in diagram.selection
            inside = elt.in(rect)

            if inside and not selected
                # New element in selection
                diagram.selection.push(elt)
                for link in diagram.links
                    # Check if there's 2 linked element in selection, in this case the link should be in selection too
                    if (link.source is elt and link.target in diagram.selection and link not in diagram.selection) or (
                        link.target is elt and link.source in diagram.selection and link not in diagram.selection)
                        diagram.selection.push link
            else if not inside and selected
                # Element not in selection anymore
                diagram.selection.splice(diagram.selection.indexOf(elt), 1)
                for link in diagram.links
                    # Check if there's a selected link which is not in selected elements anymore
                    if (link.source is elt and link.target not in diagram.selection and link in diagram.selection) or (
                        link.target is elt and link.source not in diagram.selection and link in diagram.selection)
                        diagram.selection.splice(diagram.selection.indexOf(link), 1)
        )
        svg.tick()
    ).on("dragend.selection", ->
        sel = svg.svg.select("rect.selection")
        if not sel.empty()
            x = + sel.attr("x")
            y = + sel.attr("y")
            width = + sel.attr("width")
            height = + sel.attr("height")
            svg.sync()

        svg.svg.selectAll("rect.selection").remove())


move_drag = d3.behavior.drag()
    .origin((i) -> i)
    .on('dragstart.move', (node) ->
        svg.svg.classed('dragging', true)
        svg.svg.classed('translating', true)

        if node not in diagram.selection
            if d3.event.sourceEvent.shiftKey
                diagram.selection.push(node)
            else
                diagram.selection = [node]

        node.ts = timestamp()
        if node instanceof Group
            node.ts *= -1
        svg.svg.selectAll('g.element').sort(order)

        svg.tick()
        d3.event.sourceEvent.stopPropagation()
    ).on("drag.move", (node) ->
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
    ).on('dragend.move', (node) ->
        svg.svg.classed('dragging', false)
        svg.svg.classed('translating', false)
        for node in diagram.elements
            node.fixed = false

        diagram.dragging = false
        if not $(d3.event.sourceEvent.target).closest('.inside').size()
            for node in diagram.selection
                if node in diagram.elements
                    diagram.elements.splice(diagram.elements.indexOf(node), 1)

                for lnk in diagram.links.slice()
                    if node == lnk.source or node == lnk.target
                        index = diagram.links.indexOf(lnk)
                        if index >= 0
                            diagram.links.splice(index, 1)
            diagram.selection = []
        svg.sync(true))

nsweo_resize_drag = d3.behavior.drag()
    .on("dragstart.resize", (handle) ->
        svg.svg.classed('dragging', true)
        svg.svg.classed('resizing', true)
        node = d3.select($(@).closest('.element').get(0)).data()[0]
        diagram._origin = mouse_xy svg.svg.node()
        node.ox = node.x
        node.oy = node.y
        node.owidth = node.width()
        node.oheight = node.height()
        node.fixed = true
        d3.event.sourceEvent.stopPropagation()
    ).on("drag.resize", (handle) ->
        nodes = d3.select($(@).closest('.element').get(0))
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
    ).on("dragend.resize", (handle) ->
        svg.svg.classed('dragging', false)
        svg.svg.classed('resizing', false)
        node = d3.select($(@).closest('.element').get(0)).data()[0]
        node.ox = node.oy = node.owidth = node.oheight = null
        node.fixed = false
        svg.sync(true))


anchor_link_drag = d3.behavior.drag()
    .on("dragstart.link", (anchor) ->
        svg.svg.classed('dragging', true)
        svg.svg.classed('linking', true)
        d3.event.sourceEvent.stopPropagation()
    ).on("drag.link", (anchor) ->
        if not diagram.linking.length
            node = d3.select($(@).closest('.element').get(0)).data()[0]
            type = diagram.last_types.link
            link = new type(node, new Mouse(0, 0, ''))
            link.source_anchor = anchor
            diagram.linking.push(link)
            svg.sync()

        link = diagram.linking[0]
        evt = d3.event.sourceEvent
        if evt.type == 'touchmove'
            target = document.elementFromPoint(evt.targetTouches[0].clientX, evt.targetTouches[0].clientY)
        else
            target = evt.target

        $anchor = $(target).closest('.anchor')
        if $anchor.size()
            $node = $anchor.closest('.element')
        else
            $node = $(target).closest('.element')
        if $node.size()
            link.target = $node.get(0).__data__
            if $anchor.size()
                link.target_anchor = +$anchor.attr('data-anchor')
            else
                link.target_anchor = null
        else
            if link.target not instanceof Mouse
                link.target = new Mouse(0, 0, '')
            link.target.x = link.source.x + d3.event.x
            link.target.y = link.source.y + d3.event.y
        svg.tick()
    ).on("dragend.link", (anchor) ->
        svg.svg.classed('dragging', false)
        svg.svg.classed('linking', false)
        if diagram.linking.length
            link = diagram.linking[0]
            diagram.linking = []
            if link.target instanceof Mouse
                svg.sync()
            else
                diagram.links.push link
                svg.sync(true))

mouse_node = (nodes) ->
    nodes.call(edit_it, (node) ->
        edit((-> [node.text, node.attrs?.color, node.attrs?.fillcolor]), ((txt) -> node.text = txt)))


mouse_link = (link) ->
    link
        .call(edit_it, (lnk) ->
            nearest = lnk.nearest mouse_xy(svg.svg.node())
            if nearest is lnk.source
                edit((-> [lnk.text.source, null, null]), ((txt) -> lnk.text.source = txt))
            else
                edit((-> [lnk.text.target, null, null]), ((txt) -> lnk.text.target = txt)))

link_drag = d3.behavior.drag()
    .on("dragstart.link", (link) ->
        if not d3.event.sourceEvent.shiftKey
            diagram.selection = []
        diagram.selection.push(link)
        svg.tick()
        svg.svg.classed('dragging', true)
        svg.svg.classed('linking', true)
        d3.event.sourceEvent.stopPropagation()
    ).on("drag.link", (link) ->
        if not diagram.linking.length
            diagram.links.splice(diagram.links.indexOf(link), 1)
            mouse = new Mouse(d3.event.x, d3.event.y, '')
            nearest = link.nearest mouse
            if link.source == nearest
                link.source = link.target
                link.source_anchor = link.target_anchor

            link.target = mouse
            link.target_anchor = null
            diagram.linking.push(link)
            svg.sync()

        evt = d3.event.sourceEvent
        if evt.type == 'touchmove'
            target = document.elementFromPoint(evt.targetTouches[0].clientX, evt.targetTouches[0].clientY)
        else
            target = evt.target

        link = diagram.linking[0]
        $anchor = $(target).closest('.anchor')
        if $anchor.size()
            $node = $anchor.closest('.element')
        else
            $node = $(target).closest('.element')
        if $node.size()
            link.target = $node.get(0).__data__
            if $anchor.size()
                link.target_anchor = +$anchor.attr('data-anchor')
            else
                link.target_anchor = null
        else
            if link.target not instanceof Mouse
                link.target = new Mouse(0, 0, '')
            link.target.x = d3.event.x
            link.target.y = d3.event.y
        svg.tick()
    ).on("dragend.link", (anchor) ->
        svg.svg.classed('dragging', false)
        svg.svg.classed('linking', false)
        if diagram.linking.length
            link = diagram.linking[0]
            diagram.linking = []
            if link.target instanceof Mouse
                svg.sync()
            else
                diagram.links.push link
                svg.sync(true))

floating = null

extern_drag = d3.behavior.drag()
    .on('dragstart.extern', ->
        return if floating
        $elt = $ @
        floating =
            $elt: $(@.cloneNode(true))
            offset:
                top: $elt.parent().offset().top - $elt.outerHeight() / 2
                left: $elt.parent().offset().left - $elt.outerWidth() / 2
        $('body').append(
            floating.$elt
                .css(position: 'fixed'))
        d3.event.sourceEvent.stopPropagation()
    ).on("drag.extern", ->
        floating.$elt.css(top: floating.offset.top + d3.event.y, left: floating.offset.left + d3.event.x)
    ).on('dragend.extern', ->
        return if not floating
        x = floating.$elt.offset().left - $('#diagram').offset().left + floating.$elt.outerWidth() / 2
        y = floating.$elt.offset().top - $('#diagram').offset().top + floating.$elt.outerHeight() / 2
        x = (x - diagram.zoom.translate[0]) /  diagram.zoom.scale
        y = (y - diagram.zoom.translate[1]) /  diagram.zoom.scale
        x = diagram.snap.x * Math.floor(x / diagram.snap.x)
        y = diagram.snap.y * Math.floor(y / diagram.snap.y)
        type = floating.$elt.attr('data-type')
        node_add(type, x, y)
        floating.$elt.remove()
        floating = null
    )


edit_it = (node, fun) ->
    node
        .on('dblclick', fun)
        .dblTap(fun)
