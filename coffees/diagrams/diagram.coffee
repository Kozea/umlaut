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


class Diagram extends Base
    @init_types: ->
        elements: {}
        groups: {}
        links: {}

    constructor: ->
        super
        @title = 'Untitled ' + @label
        @linkstyle = new LinkStyles.Rectangular()
        @zoom =
            scale: 1
            translate: [0, 0]

        @elements = []
        @links = []
        @groups = []

        @snap =
            x: 25
            y: 25
            a: 22.5

        @selection = []
        @linking = []
        @last_types =
            link: null
            element: null
            group: null

        @mouse = new Mouse(0, 0, '')
        @dragging = false
        @groupping = false
        @force_conf =
            gravity: .1
            distance: 20
            strengh: 1
            friction: .9
            theta: .8
            charge_base: 2000

    start_force: ->
        @force = d3.layout.force()
            .gravity(@force_conf.gravity)
            .linkDistance(@force_conf.distance)
            .linkStrength(@force_conf.strengh)
            .friction(@force_conf.friction)
            .theta(@force_conf.theta)
            .charge((node) => - @force_conf.charge_base - node.width() * node.height() / 4)
            .size([svg.width, svg.height])

        @force.on('tick', => svg.tick())
        @force.on('end', generate_url)
        svg.sync()
        @force.start()

    markers: ->
        markers = {}
        for name, type of @types.links
            markers[type.marker.id] = type.marker
        val for key, val of markers

    to_svg: ->
        css = ''
        for rule in d3.select('#style').node().sheet.cssRules
            if rule.selectorText.match(/^svg\s/)
                if not rule.cssText.match(/:hover/) and not rule.cssText.match(/:active/) and not rule.cssText.match(/transition/)
                    css += rule.cssText.replace(/svg\s/g, '')

        svg_clone = d3.select(svg.svg.node().cloneNode(true))
        svg_clone.select('.background').remove()
        svg_clone.selectAll('.handles,.anchors').remove()
        svg_clone.selectAll('.node').classed('selected', false)
        svg_clone.selectAll('.ghost').remove()
        svg_clone.select('defs').append('style').text(css)
        margin = 50
        rect = svg.svg.select('.root').node().getBoundingClientRect()
        svg_clone.select('.root').attr('transform', "translate(#{diagram.zoom.translate[0] - rect.left + margin},#{diagram.zoom.translate[1] - rect.top + margin})scale(#{diagram.zoom.scale})")
        svg_clone.select('#title').attr('x', rect.width / 2 + margin)
        content = svg_clone.html()
        # Some browser doesn't like innerHTML on <svg>
        if not content?
            content = $(svg_clone.node()).wrap('<div>').parent().html()
        "<svg xmlns='http://www.w3.org/2000/svg' width='#{rect.width + 2 * margin}' height='#{rect.height + 2 * margin}'>#{content}</svg>"

    nodes: ->
        @elements.concat(@groups)

    objectify: ->
        name: @constructor.name
        title: @title
        linkstyle: @linkstyle.cls.name
        zoom: @zoom
        elements: @elements.map (elt) -> elt.objectify()
        groups: @groups.map (grp) -> grp.objectify()
        links: @links.map (lnk) -> lnk.objectify()
        force: if @force then true else false

    hash: ->
        LZString.compressToBase64(JSON.stringify(@objectify()))

    loads: (obj) ->
        if obj.title
            @title = obj.title
        if obj.linkstyle
            @linkstyle = new LinkStyles[capitalize(obj.linkstyle)]()
        if obj.zoom
            @zoom = obj.zoom

        for grp in (obj.groups or [])
            group_type = @types.groups[grp.name]
            group = new group_type(grp.x, grp.y, grp.text, false)
            group._width = grp.width or null
            group._height = grp.height or null
            group._rotation = grp.rotation or 0
            group.attrs = grp.attrs
            @groups.push(group)

        for elt in obj.elements
            element_type = @types.elements[elt.name]
            element = new element_type(elt.x, elt.y, elt.text, false)
            element._width = elt.width or null
            element._height = elt.height or null
            element._rotation = elt.rotation or 0
            element.attrs = elt.attrs
            @elements.push(element)

        for lnk in obj.links
            link_type = @types.links[lnk.name] or @types.links[lnk.name.replace('Link', '')]
            link = new link_type(@nodes()[lnk.source], @nodes()[lnk.target], lnk.text)
            link.source_anchor = lnk.source_anchor
            link.target_anchor = lnk.target_anchor
            link.attrs = lnk.attrs
            @links.push(link)

        if obj.force
            @start_force()

Diagrams =
    _get: (type) ->
        # Compat
            @[type] or @[type.replace('Diagram', '')]
