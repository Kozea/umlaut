class Element
    constructor: (@x, @y, @text) ->
        @_margin = x: 10, y: 5

    center: ->
        x: @x + (@_txt_bbox and @_txt_bbox.width or 0) / 2 + @_margin.x
        y: @y + (@_txt_bbox and @_txt_bbox.height or 0) / 2 + @_margin.y


    width: =>
        @_txt_bbox.width + 2 * @_margin.x

    height: =>
        @_txt_bbox.height + 2 * @_margin.y


class Square extends Element
    path: ->
      "M 0 0 L #{@width()} 0 L #{@width()} #{@height()} L 0 #{@height()} z"

class Lozenge extends Element
    path: ->
      "M -10 0 L #{@width()} 0 L #{@width() + 10} #{@height()} L 0 #{@height()} z"


class Link
    constructor: (@elt1, @elt2) ->

    source: =>
        @elt1.center()

    target: =>
        @elt2.center()

e1 = new Lozenge(1, 2, 'Yop')
e2 = new Square(343, 232, "That's right")
e3 = new Lozenge(130, 622, 'So what ?')
e4 = new Square(532, 92, "WTF")


l1 = new Link(e1, e2)
l2 = new Link(e1, e3)
l3 = new Link(e2, e4)
l4 = new Link(e4, e1)


@data =
    elements: [e1, e2, e3, e4]
    links: [l1, l2, l3, l4]

svg = null

drag = d3.behavior.drag()
    .origin(Object)
    .on("drag", (elt) ->
        elt.x = d3.event.x
        elt.y = d3.event.y
        draw()
    )

draw = =>
    diagonal = d3.svg.diagonal()
        .source((elt) -> elt.source())
        .target((elt) -> elt.target())
        .projection((d) -> [d.x, d.y])

    links = svg.selectAll('path.link')
        .data(@data.links)

    links
        .enter()
            .append("path")
            .attr("class", "link")

    elements = svg.selectAll('g.element')
        .data(@data.elements)

    # Update

    # Enter
    element = elements.enter()
        .append('g')
        .attr('class', 'element')
        .call(drag)

    element
        .append('path')
        .attr('class', 'shape')

    element.append('text')
        .attr('x', (elt) -> elt._margin.x)
        .attr('y', (elt) -> elt._margin.y)


    # Update + Enter
    elements
        .attr('transform', (elt) -> "translate(#{elt.x}, #{elt.y})")

    elements
        .select('text')
        .text((elt) -> elt.text)
        .each((elt) -> elt._txt_bbox = @getBBox())

    elements
        .select('path.shape')
        .attr('d', (elt) -> elt.path())

    # Exit
    elements.exit()
        .remove()

    links
        .attr("d", diagonal)

    links.exit()
        .remove()


margin =
  top: 20
  right: 20
  bottom: 30
  left: 40


svg = d3.select("#viz")
    .append("svg:svg")
    .attr("width", @innerWidth)
    .attr("height", @innerHeight - 25)
d3.select('body')
    .on('keydown', =>
        data.elements.push(new Square(Math.random() * @innerWidth, Math.random() * @innerHeight, Math.random().toString()))
    )

draw()

