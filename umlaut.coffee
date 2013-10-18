class Element
    constructor: (@x, @y, @text, @fixed=false) ->
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
        @value = Math.random() * 10

    source: =>
        @elt1.center()

    target: =>
        @elt2.center()

@data = data = {}
@state =
    selection: []
    mouse:
        x: 0
        y: 0


@combinations = (elts, n) ->
    return [] if elts.length < n
    return [elts] if elts.length == n
    result = []
    f = (prefix, elts) ->
        i = 0

        while i < elts.length
            combination = prefix.concat(elts[i])
            if combination.length == n
                result.push combination
            f combination, elts.slice(i + 1)
            i++

    f [], elts
    result

data.elts = [
    new Lozenge(1, 2, 'Yop'),
    new Square(343, 232, "That's right"),
    new Lozenge(130, 622, 'So what ?'),
    new Square(532, 92, "WTF")
]

data.lnks = [
    new Link(@data.elts[0], @data.elts[1]),
    new Link(@data.elts[0], @data.elts[2]),
    new Link(@data.elts[1], @data.elts[3]),
    new Link(@data.elts[3], @data.elts[0])
]


width = @innerWidth
height = @innerHeight - 25

svg = d3.select("body")
    .append("svg")
    .attr("width", width)
    .attr("height", height)

force = d3.layout.force()
    .gravity(.15)
    .distance(100)
    .charge(-1000)
    .size([width, height])

drag = force.drag()
    .on("dragstart", (elt) ->
        if d3.event.sourceEvent.shiftKey
            state.selection.push(elt)
        else
            d3.selectAll('.selected').classed('selected', false)
            state.selection = [elt]

        d3.select(this).classed('selected', true)
    )

force.nodes(data.elts)
    .links(data.lnks)


diagonal = d3.svg.diagonal()
    .source((elt) -> elt.source())
    .target((elt) -> elt.target())
    .projection((d) -> [d.x, d.y])

element = null
link = null

svg
    .on('click', ->
        if d3.event.target == @
            d3.selectAll('.selected').classed('selected', false)
            state.selection = []
    )
svg
    .append('g')
    .attr('class', 'links')

svg
    .append('g')
    .attr('class', 'elements')


sync = ->
    link = svg.select('g.links').selectAll('path.link')
        .data(data.lnks)

    link
        .enter()
            .append("path")
            .attr("class", "link")

    element = svg.select('g.elements').selectAll('g.element')
        .data(data.elts)


    # Update

    # Enter
    element.enter()
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
    element
        .select('text')
        .text((elt) -> elt.text)
        .each((elt) -> elt._txt_bbox = @getBBox())

    element
        .select('path.shape')
        .attr('d', (elt) -> elt.path())

    # Exit
    element.exit()
        .remove()

    link.exit()
        .remove()

    tick()

    force.start()


tick = ->
    element.attr("transform", ((d) -> "translate(" + d.x + "," + d.y + ")"))

    link
        .attr("d", diagonal)


d3.select('html')
    .on('mousemove', ->
        state.mouse = d3.mouse(@)
    )
    .on('keydown', ->
        if d3.event.which == 83 # s
            new_elt = new Square(state.mouse[0], state.mouse[1], 'New element')
            data.elts.push(new_elt)
            for elt in state.selection
                data.lnks.push(new Link(elt, new_elt))
            sync()

        if d3.event.which == 76 # l
            for combination in combinations(state.selection, 2)
                data.lnks.push(new Link(combination[0], combination[1]))
            sync()

        if d3.event.which == 80 # p
            for elt in state.selection
                elt.fixed = not elt.fixed

        if d3.event.which == 69 # e
            for elt in state.selection
                elt.text = prompt("Enter a name for #{elt.text}:")
            sync()

        if d3.event.ctrlKey and d3.event.which == 65 # C-a
            state.selection = data.elts
            d3.selectAll('g.element').classed('selected', true)
            d3.event.preventDefault()

        if d3.event.which == 46 # del
            for elt in state.selection
                data.elts.splice(data.elts.indexOf(elt), 1)
                for lnk in data.lnks.slice()
                    if elt == lnk.elt1 or elt == lnk.elt2
                        data.lnks.splice(data.lnks.indexOf(lnk), 1)
            state.selection = []
            d3.selectAll('g.element').classed('selected', false)
            sync()
    )

force.on('tick', tick)
sync()
combinations(data.elts, 2)
