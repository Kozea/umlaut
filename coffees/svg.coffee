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


mouse_xy = (e) ->
    m = d3.mouse(e)

    x: (m[0] - diagram.zoom.translate[0]) / diagram.zoom.scale
    y: (m[1] - diagram.zoom.translate[1]) / diagram.zoom.scale


class Svg extends Base
    constructor: ->
        super
        article = d3.select("article").node()
        @width = article.clientWidth
        @height = article.clientHeight or 500
        @title = d3.select('#editor h2')
            .on('dblclick', ->
                edit((-> diagram.title), ((txt) -> diagram.title = txt)))

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

        d3.select("article")
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

        @svg.on("mousedown", (event) =>
            return if not d3.select(d3.event.target).classed('background') or d3.event.ctrlKey or d3.event.which is 2
            # return if diagram.dragging or d3.event.ctrlKey or d3.event.which is 2
            if d3.event.altKey and d3.event.shiftKey
                diagram.groupping = true

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
        )

        d3.select(window).on("mousemove", =>
            return if d3.event.ctrlKey
            mouse = mouse_xy(@svg.node())
            diagram.mouse.lasts.push
                x: diagram.mouse.x - mouse.x
                y: diagram.mouse.y - mouse.y

            diagram.mouse.dynamic_rotation()
            diagram.mouse.lasts.shift()

            diagram.mouse.x = mouse.x
            diagram.mouse.y = mouse.y

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

                @svg.selectAll('g.node').each((elt) ->
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
                type = diagram.last_types.group or diagram.types.groups[0]
                if type
                    nth = diagram.groups.filter((grp) -> grp instanceof type).length + 1
                    grp = new type(x + width / 2, y + height / 2, "#{type.name} ##{nth}", not diagram.force)
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
            .attr('width', diagram.snap.x)
            .attr('height', diagram.snap.y)
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


    sync: (persist=false) ->
        @zoom.scale(diagram.zoom.scale)
        @zoom.translate(diagram.zoom.translate)
        @zoom.event(d3.select('#bg'))
        @title.text(diagram.title)

        group = @svg.select('g.groups').selectAll('g.group').data(diagram.groups.sort(order))
        element = @svg.select('g.elements').selectAll('g.element').data(diagram.elements.sort(order))
        link = @svg.select('g.links').selectAll('g.link').data(diagram.links.concat(diagram.linking))

        group.enter().call(enter_node)
        element.enter().call(enter_node)
        link.enter().call(enter_link)

        group.call(update_node)
        element.call(update_node)
        link.call(update_link)

        group.exit().remove()
        element.exit().remove()
        link.exit().remove()

        @tick()

        if persist and not diagram.force
            generate_url()

        if diagram.force
            diagram.force.stop()
            diagram.force.nodes(diagram.nodes()).links(diagram.links)
            diagram.force.start()

    tick: ->
        @svg.select('g.groups').selectAll('g.group').call(tick_node)
        @svg.select('g.elements').selectAll('g.element').call(tick_node)
        @svg.select('g.links').selectAll('g.link').call(tick_link)

    resize: ->
        article = d3.select("article").node()
        @width = article.clientWidth
        @height = article.clientHeight or 500
        @svg
            .attr("width", @width)
            .attr("height", @height)
        d3.select('.background')
            .attr("width", @width)
            .attr("height", @height)
