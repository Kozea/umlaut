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


enter_node = (nodes, connect=true) ->
    g = nodes
        .append('g')
        .attr('class', (node) -> 'node ' + if node instanceof Group then 'group' else 'element')
    g.append('path').attr('class', 'ghost')
    g.append('path').attr('class', (node) -> "shape fill-#{node.cls.fill} stroke-#{node.cls.stroke}")
    g.append('text')
    if not connect
        return

    g.append('g')
        .attr('class', 'handles')
        .each((node) ->
            d3.select(this)
            .selectAll('.handle')
            .data(node.handle_list())
            .enter()
                .append('path')
                .attr('class', (handle) -> "handle #{handle}")
                .call(nsweo_resize_drag))

    g.append('g')
        .attr('class', 'anchors')
        .each((node) ->
            d3.select(this)
            .selectAll('.anchor')
            .data(node.anchor_list())
            .enter()
                .append('path')
                .attr('class', (anchor) -> "anchor #{anchor}")
                .attr('data-anchor', (anchor) -> anchor)
                .call(anchor_link_drag))

    g.call(move_drag)
    g.call(mouse_node)


write_text = (txt, text) ->
    txt.selectAll('tspan').remove()
    for line, i in text.split('\n')
        tspan = txt.append('tspan')
            .text(line)
            .attr('x', 0)
        if i != 0
            tspan
                .attr('dy', '1.2em')


update_node = (nodes) ->
    nodes
        .select('text')
        .each((node) ->
            txt = d3.select @
            current_text = txt.selectAll('tspan')[0].map((e) -> d3.select(e).text()).join('\n')
            return if node.text == current_text
            txt.call(write_text, node.text))
        .each((node) -> node.set_txt_bbox(@getBBox()))
        .attr('x', (node) -> node.txt_x())
        .attr('y', (node) -> node.txt_y())
        .selectAll('tspan')
            .attr('x', (node) -> node.txt_x())

    nodes.select('.shape')
        .attr('class', (node) -> "shape fill-#{node.cls.fill} stroke-#{node.cls.stroke}")
        .attr('style', node_style)
        .attr('d', (node) -> node.path())
    nodes.select('.ghost').attr('d', (node) -> Rect::path.apply(node))

    nodes.call(update_handles)
    nodes.call(update_anchors)


enter_link = (links, connect=true) ->
    g = links
        .append('g')
        .attr("class", "link")

    g
        .append("path")
        .attr('class', 'ghost')

    g
        .append("path")
        .attr('class', (link) -> "shape #{link.cls.type}")
        .attr("marker-start", (link) -> "url(##{link.marker_start?.id or link.cls.marker_start.id})")
        .attr("marker-end", (link) -> "url(##{link.marker_end?.id or link.cls.marker_end.id})")

    g
        .each((link) ->
            node = d3.select(@)
            if link.text.source
                txt = node
                    .append("text")
                    .attr('class', "start")
                    .call(write_text, link.text.source)
                link._source_bbox = txt.node().getBBox()

            if link.text.target
                txt = node
                    .append("text")
                    .attr('class', "end")
                    .call(write_text, link.text.target)
                link._target_bbox = txt.node().getBBox())

    if connect
        g.call(mouse_link)
        g.call(link_drag)


update_link = (links) ->
    links
        .each((link) ->
            d3.select(@).selectAll('path').attr('d', link.path())
                .attr("marker-start", "url(##{link.marker_start?.id or link.cls.marker_start.id})")
                .attr("marker-end", "url(##{link.marker_end?.id or link.cls.marker_end.id})"))

    links
        .each((link) ->
            g = d3.select(@)
            txt = g.select('text.start').node()
            if link.text.source and not txt
                g.append('text')
                .attr('class', 'start')
            txt = g.select('text.end').node()
            if link.text.target and not txt
                g.append('text')
                .attr('class', 'end')
            g.select('.shape')
                .attr('style', node_style))
    links
        .select('text.start')
        .each((link) ->
            txt = d3.select @
            text = txt.text()
            return if link.text.source == text and link._source_bbox?
            if link.text.source.trim() == ''
                txt.remove()
                return
            txt.call(write_text, link.text.source)
            link._source_bbox = txt.node().getBBox())

    links
        .select('text.end')
        .each((link) ->
            txt = d3.select @
            text = txt.text()
            return if not link.text.target == text and link._target_bbox?
            if link.text.target.trim() == ''
                txt.remove()
                return
            txt.call(write_text, link.text.target)
            link._target_bbox = txt.node().getBBox())

update_handles = (nodes) ->
    nodes.each (node) ->
        s = node.cls.handle_size
        d3.select(@)
            .selectAll('.handle')
            .data(node.handle_list())
            .attr('d', (handle) ->
                h = node.handles[handle]()
                if handle != 'O'
                    signs = cardinal_to_direction handle
                    "M #{h.x} #{h.y}
                     L #{h.x + signs.x * s} #{h.y}
                     L #{h.x + signs.x * s} #{h.y  + signs.y *  s}
                     L #{h.x} #{h.y + signs.y * s}
                    z"
                else
                    "M #{h.x} #{h.y}
                     L #{h.x} #{h.y - 2 * s}
                     A #{s} #{s} 0 1 1 #{h.x} #{h.y - 4 * s}
                     A #{s} #{s} 0 1 1 #{h.x} #{h.y - 2 * s}
                    ")

update_anchors = (nodes) ->
    nodes.each (node) ->
        s = node.cls.handle_size
        d3.select(@)
            .selectAll('.anchor')
            .data(node.anchor_list())
            .attr('transform', (anchor) ->
                a = node.anchors[anchor]()
                "rotate(#{to_svg_angle(anchor)}, #{a.x - node.x}, #{a.y - node.y})")
            .attr('d', (anchor) ->
                a = node.anchors[anchor]()
                if undefined in [a.x, a.y, node.x, node.y]
                    return 'M 0 0'
                a.x -= node.x
                a.y -= node.y
                "M #{a.x} #{a.y}
                 L #{a.x} #{a.y + s}
                 L #{a.x + s} #{a.y}
                 L #{a.x} #{a.y - s}
                 z")

tick_node = (nodes) ->
    nodes
        .attr("transform", ((node) -> "translate(#{node.x},#{node.y})rotate(#{to_svg_angle(node._rotation)})"))
        .classed('selected', (node) -> node in diagram.selection)

tick_link = (links) ->
    links
        .classed('selected', (link) -> link in diagram.selection)

    links
        .each((link) ->
            d3.select(@).selectAll('path').attr('d', link.path()))

    links
        .select('text.start')
        .attr('transform', (link) ->
            bb = link._source_bbox
            pos =
                x: link.text_margin + bb.width / 2
                y: - link.text_margin - bb.height / 2
            delta = rotate(pos, link.o1)
            "translate(#{link.a1.x + delta.x}, #{link.a1.y + delta.y})")

    links
        .select('text.end')
        .attr('transform', (link) ->
            bb = link._target_bbox
            pos =
                x: link.text_margin + bb.width / 2
                y: - link.text_margin - bb.height / 2
            delta = rotate(pos, link.o2)
            "translate(#{link.a2.x + delta.x}, #{link.a2.y + delta.y})")

enter_marker = (markers, open=false) ->
    markers
        .append('marker')
            .append('path')

update_marker = (markers) ->
    markers
        .attr('id', (m) -> m.id)
        .attr('class', (m) -> "marker fill-#{if m.open then 'bg' else 'fg'} stroke-fg")
        .attr('viewBox', (m) -> m.viewbox())
        .attr('markerUnits', 'userSpaceOnUse')
        .attr('markerWidth', (m) -> m.width())
        .attr('markerHeight', (m) -> m.height())
        .attr('orient', 'auto')
        .each((m) ->
            d3.select(@)
                .select('path')
                    .attr('d', m.path()))
