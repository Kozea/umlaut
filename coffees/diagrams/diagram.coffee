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

        @snap =
            x: 25
            y: 25
            a: 22.5

        @selection = []
        @linking = []
        @last_types =
            link: null
            element: null

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
        # markers = {}
        # for name, type of @types.links
        #     markers[type.marker_start.id] = type.marker_start
        #     markers[type.marker_end.id] = type.marker_end
        # val for key, val of markers
        markers = []
        for name, marker of Markers
            if name.indexOf('_') is 0
                continue
            markers.push new marker(false, false)
            markers.push new marker(true, false)
            markers.push new marker(false, true)
            markers.push new marker(true, true)
        markers

    to_svg: ->
        css = ''
        for rule in d3.select('#style').node().sheet.cssRules
            if rule.selectorText?.match(/^svg\s/)
                if not rule.cssText.match(/:hover/) and not rule.cssText.match(/:active/) and not rule.cssText.match(/transition/)
                    css += rule.cssText.replace(/svg\s/g, '')

        svg_clone = d3.select(svg.svg.node().cloneNode(true))
        svg_clone.select('.background').remove()
        svg_clone.selectAll('.handles,.anchors').remove()
        svg_clone.selectAll('.element').classed('selected', false)
        svg_clone.selectAll('.ghost').remove()
        svg_clone.select('defs').append('style').text(css)
        margin = 50
        rect = svg.svg.select('.root').node().getBoundingClientRect()
        svg_clone.select('.root').attr('transform', "translate(#{diagram.zoom.translate[0] - rect.left + margin},#{diagram.zoom.translate[1] - rect.top + margin})scale(#{diagram.zoom.scale})")
        svg_clone.select('#title').attr('x', rect.width / 2 + margin)
        svg_clone.append('image')
            .attr('xlink:href', 'data:image/png;base64,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')
            .attr('x', 10)
            .attr('width', 100)
            .attr('y', rect.height + 50)
            .attr('height', 39)
        content = svg_clone.html()
        # Some browser doesn't like innerHTML on <svg>
        if not content?
            content = $(svg_clone.node()).wrap('<div>').parent().html()
        "<svg xmlns='http://www.w3.org/2000/svg'  xmlns:xlink='http://www.w3.org/1999/xlink' width='#{rect.width + 2 * margin}' height='#{rect.height + 2 * margin}'><!--Generated with umlaut (http://kozea.github.io/umlaut/) (c) Mounier Florian Kozea 2013 on #{(new Date()).toString()}-->#{content}</svg>"

    objectify: ->
        name: @constructor.name
        title: @title
        linkstyle: @linkstyle.cls.name
        zoom: @zoom
        elements: @elements.map (elt) -> elt.objectify()
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

        for elt in obj.elements
            element_type = @types.elements[elt.name]
            element = new element_type(elt.x, elt.y, elt.text, false)
            element._width = elt.width or null
            element._height = elt.height or null
            element._rotation = elt.rotation or 0
            element.attrs = elt.attrs or {}
            @elements.push(element)

        for lnk in obj.links
            link_type = @types.links[lnk.name] or @types.links['Link']
            link = new link_type(@elements[lnk.source], @elements[lnk.target], lnk.text)
            link.source_anchor = lnk.source_anchor
            link.target_anchor = lnk.target_anchor
            link.attrs = lnk.attrs or {}
            if link.attrs.arrowhead
                link.marker_end = Markers._get(link.attrs.arrowhead)
            if link.attrs.arrowtail
                link.marker_start = Markers._get(link.attrs.arrowtail, true)
            @links.push(link)

        if obj.force
            @start_force()

Diagrams =
    _get: (type) ->
        # Compat
            @[type] or @[type.replace('Diagram', '')]
