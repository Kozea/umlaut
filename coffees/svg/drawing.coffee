enter_node = (node) ->
    g = node
        .append('g')
        .attr('class', (node) -> if node instanceof Group then 'group' else 'element')
    g.append('path').attr('class', 'ghost').call(ghost_drag)
    g.append('path').attr('class', (node) -> "shape fill-#{node.cls.fill} stroke-#{node.cls.stroke}")
    g.append('text')
    g.call(force_drag(svg.force.drag()))
    g.call(mouse_node)


update_node = (node) ->
    node
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

    node
        .each((node) ->
            $(@).find('path').attr('d', node.path()))


enter_link = (link) ->
    g = link
        .append('g')
        .attr("class", "link")

    g
        .append("path")
        .attr('class', 'ghost')

    g
        .append("path")
        .attr('class', (lnk) -> "shape #{lnk.cls.type}")
        .attr("marker-end", (lnk) -> "url(##{lnk.cls.marker.id})")

    g
        .append("text")
        .attr('class', "start")

    g
        .append("text")
        .attr('class', "end")

    g.call(mouse_link)


update_link = (link) ->
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

tick_node = (node) ->
    node
        .attr("transform", ((node) -> "translate(#{node.x},#{node.y})rotate(#{node._rotation})"))
        .classed('moving', (node) -> not node.fixed)
        .classed('selected', (node) -> node in diagram.selection)

tick_link = (link) ->
    link
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
