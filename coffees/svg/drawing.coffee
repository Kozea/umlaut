enter_node = (nodes, connect=true) ->
    g = nodes
        .append('g')
        .attr('class', (node) -> if node instanceof Group then 'group' else 'element')
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
                .call(mouse_anchor)
                .call(anchor_link_drag))

    g.call(force_drag(svg.force.drag()))
    g.call(mouse_node)


update_node = (nodes) ->
    nodes
        .select('text')
        .each((node) ->
            txt = d3.select @
            return if node.text == txt.text
            txt.selectAll('tspan').remove()
            for line, i in node.text.split('\n')
                tspan = txt.append('tspan')
                    .text(line)
                    .attr('x', 0)
                if i != 0
                    tspan
                        .attr('dy', '1.2em'))
        .each((node) -> node.set_txt_bbox(@getBBox()))
        .attr('x', (node) -> node.txt_x())
        .attr('y', (node) -> node.txt_y())
        .selectAll('tspan')
            .attr('x', (node) -> node.txt_x())

    nodes.select('.shape')
        .attr('class', (node) -> "shape fill-#{node.cls.fill} stroke-#{node.cls.stroke}")
        .attr('d', (node) -> node.path())
    nodes.select('.ghost').attr('d', (node) -> Rect::path.apply(node))


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
        .attr("marker-end", (link) -> "url(##{link.cls.marker.id})")

    g
        .append("text")
        .attr('class', "start")

    g
        .append("text")
        .attr('class', "end")

    if connect
        g.call(mouse_link)
        g.call(link_drag)


update_link = (links) ->
    links
        .each((link) ->
            $(@).find('path').attr('d', link.path()))

    links
        .select('text.start')
        .each((link) ->
            txt = d3.select @
            return if link.text.source == txt.text
            txt.selectAll('tspan').remove()
            for line, i in link.text.source.split('\n')
                tspan = txt.append('tspan')
                    .text(line)
                    .attr('x', 0)
                if i != 0
                    tspan
                        .attr('dy', '1.2em'))

    links
        .select('text.end')
        .each((link) ->
            txt = d3.select @
            return if not link.text.target == txt.text
            txt.selectAll('tspan').remove()
            for line, i in link.text.target.split('\n')
                tspan = txt.append('tspan')
                    .text(line)
                    .attr('x', 0)
                if i != 0
                    tspan
                        .attr('dy', '1.2em'))

tick_node = (nodes) ->
    nodes
        .attr("transform", ((node) -> "translate(#{node.x},#{node.y})rotate(#{node._rotation})"))
        .classed('moving', (node) -> not node.fixed)
        .classed('selected', (node) -> node in diagram.selection)
        .each((node) ->
            # Handles
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
            # Anchors
            s = s / 2
            d3.select(@)
                .selectAll('.anchor')
                .data(node.anchor_list())
                .attr('d', (anchor) ->
                    a = node.anchors[anchor]()
                    a.x -= node.x
                    a.y -= node.y
                    signs = cardinal_to_direction anchor
                    "M #{a.x + signs.x * s} #{a.y + s + signs.y * s}
                     A #{s} #{s} 0 1 1 #{a.x + signs.x * s} #{a.y - s + signs.y * s}
                     A #{s} #{s} 0 1 1 #{a.x + signs.x * s} #{a.y + s + signs.y * s}"))

tick_link = (links) ->
    links
        .classed('selected', (link) -> link in diagram.selection)

    links
        .each((link) ->
            $(@).find('path').attr('d', link.path()))

    links
        .select('text.start')
        .attr('transform', (link) -> "translate(#{link.a1.x}, #{link.a1.y})")
        .attr('dx', (link) ->
            if link.d1 in ['N', 'E']
                link.text_margin + @getBBox().width / 2
            else
                - (link.text_margin + @getBBox().width / 2))
        .attr('dy', (link) ->
            if link.d1 in ['N', 'E']
                 - (@getBBox().height + link.text_margin)
            else
                link.text_margin)

    links
        .select('text.end')
        .attr('transform', (link) -> "translate(#{link.a2.x}, #{link.a2.y})")
        .attr('dx', (link) ->
            if link.d2 in ['N', 'E']
                link.text_margin + @getBBox().width / 2
            else
                - (link.text_margin + @getBBox().width / 2))
        .attr('dy', (link) ->
            if link.d2 in ['N', 'E']
                 - (@getBBox().height + link.text_margin)
            else
                link.text_margin)
