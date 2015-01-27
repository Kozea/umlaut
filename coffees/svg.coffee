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

zoom = d3.behavior.zoom()

class Svg extends Base
  constructor: ->
    super
    article = d3.select("article").node()
    @width = article.clientWidth
    @height = article.clientHeight or 500

    @zoom = zoom
      .scale(diagram.zoom.scale)
      .translate(diagram.zoom.translate)
      .scaleExtent([.05, 5])
      .on("zoom", ->
        unless d3.event.sourceEvent?.shiftKey
          diagram.zoom.translate = d3.event.translate
          diagram.zoom.scale = d3.event.scale
          svg.sync_transform()
      ).on("zoomend", -> svg.sync(true))

    d3.select(".inside")
      .selectAll('svg')
      .data([diagram])
      .enter()
        .append("svg")
        .attr('id', "diagram")
        .attr("width", @width)
        .attr("height", @height)
        .call(@create)

    @svg = d3.select('#diagram').call(svg_selection_drag)

  sync_transform: ->
    d3.select('.root')
      .attr("transform",
       "translate(#{diagram.zoom.translate})scale(#{diagram.zoom.scale})")
    d3.select('#grid')
    .attr("patternTransform",
     "translate(#{diagram.zoom.translate})scale(#{diagram.zoom.scale})")

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

    svg
      .append('text')
      .attr('id', 'title')
      .attr('x', @width / 2)
      .attr('y', 50)
      .call(edit_it, ->
        edit((-> diagram.title), ((txt) -> diagram.title = txt), false))

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
    @sync_transform()
    @svg.select('#title').text(diagram.title)

    markers = @svg.select('defs').selectAll('marker').data(diagram.markers())
    markers.enter().call(enter_marker)
    markers.call(update_marker)
    markers.exit().remove()

    element = @svg.select('g.elements').selectAll('g.element')
      .data(diagram.elements.sort(order))
    link = @svg.select('g.links').selectAll('g.link')
      .data(diagram.links.concat(diagram.linking))

    element.enter().call(enter_node)
    link.enter().call(enter_link)

    element.call(update_node)
    link.call(update_link)

    element.exit().remove()
    link.exit().remove()

    @tick()

    if persist and not diagram.force
      generate_url()

    if diagram.force
      diagram.force.stop()
      diagram.force.nodes(diagram.elements).links(diagram.links)
      diagram.force.start()

  tick: ->
    @svg.select('g.elements').selectAll('g.element').call(tick_node)
    @svg.select('g.links').selectAll('g.link').call(tick_link)

  resize: ->
    article = d3.select(".inside").node()
    @width = article.clientWidth
    @height = article.clientHeight or 500
    @svg
      .attr("width", @width)
      .attr("height", @height)
    d3.select('.background')
      .attr("width", @width)
      .attr("height", @height)
    @svg.select('#title').attr('x', @width / 2)
