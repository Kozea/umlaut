element_add = (type) =>
    x = diagram.mouse.x
    y = diagram.mouse.y
    nth = diagram.elements.filter((elt) -> elt instanceof type).length + 1
    new_elt = new type(x, y, "#{type.name} ##{nth}", true)
    diagram.elements.push(new_elt)
    if d3.event
        d3.select('.selected').classed('selected', false)
        diagram.selection = [new_elt]

    svg.sync()

    if d3.event
        # Hack to trigger d3 drag event on newly created element
        node = null
        d3.selectAll('g.element').each((elt) ->
            if elt == new_elt
                node = @
                d3.select(node).classed('selected', true))
        mouse_evt = document.createEvent('MouseEvent')
        mouse_evt.initMouseEvent(
            d3.event.type, d3.event.canBubble, d3.event.cancelable, d3.event.view,
            d3.event.detail, d3.event.screenX, d3.event.screenY, d3.event.clientX, d3.event.clientY,
            d3.event.ctrlKey, d3.event.altKey, d3.event.shiftKey, d3.event.metaKey,
            d3.event.button, d3.event.relatedTarget)
        node.dispatchEvent(mouse_evt)

commands =
    undo:
        fun: (e) ->
            history.go(-1)
            e?.preventDefault()

        label: 'Undo'
        glyph: 'chevron-left'
        hotkey: 'ctrl+z'

    redo:
        fun: (e) ->
            history.go(1)
            e?.preventDefault()

        label: 'Redo'
        glyph: 'chevron-right'
        hotkey: 'ctrl+y'

    save:
        fun: (e) ->
            save()
            e?.preventDefault()

        label: 'Save locally'
        glyph: 'save'
        hotkey: 'ctrl+s'

    edit:
        fun: ->
            edit((->
                if diagram.selection.length == 1
                    diagram.selection[0].txt
                else
                    ''), ((txt) ->
                for elt in diagram.selection
                    elt.text = txt))
            svg.sync()
        label: 'Edit elements text'
        glyph: 'edit'
        hotkey: 'e'

    remove:
        fun: ->
            for elt in diagram.selection
                diagram.elements.splice(diagram.elements.indexOf(elt), 1)
                for lnk in diagram.links.slice()
                    if elt == lnk.source or elt == lnk.target
                        diagram.links.splice(diagram.links.indexOf(lnk), 1)
            diagram.selection = []
            d3.selectAll('g.element').classed('selected', false)
            svg.sync()
        label: 'Remove elements'
        glyph: 'remove-sign'
        hotkey: 'del'

    select_all:
        fun: (e) ->
            diagram.selection = diagram.elements.slice()
            d3.selectAll('g.element').classed('selected', true)
            e?.preventDefault()

        label: 'Select all elements'
        glyph: 'fullscreen'
        hotkey: 'ctrl+a'

    reorganize:
        fun: ->
            sel = if diagram.selection.length > 0 then diagram.selection else diagram.elements
            for elt in sel
                elt.fixed = false
            svg.sync()
        label: 'Reorganize'
        glyph: 'th'
        hotkey: 'r'

    freemode:
        fun: ->
            for elt in diagram.elements
                elt.fixed = diagram.freemode
            if diagram.freemode
                svg.force.stop()
            else
                svg.sync()
            diagram.freemode = not diagram.freemode
        label: 'Toggle free mode'
        glyph: 'send'
        hotkey: 'tab'

    link:
        fun: ->
            diagram.linking = []
            for elt in diagram.selection
                diagram.linking.push(new Link(elt, diagram.mouse))
            svg.sync()
        label: 'Link elements'
        glyph: 'arrow-right'
        hotkey: 'l'

    linkstyle:
        fun: ->
            diagram.linkstyle = switch diagram.linkstyle
                when 'curve' then 'diagonal'
                when 'diagonal' then 'rectangular'
                when 'rectangular' then 'curve'
            svg.tick()
        label: 'Change link style'
        glyph: 'retweet'
        hotkey: 'space'

    defaultscale:
        fun: ->
            svg.zoom.scale(1)
            svg.zoom.translate([0, 0])
            svg.zoom.event(svg.underlay_g)
        label: 'Reset view'
        glyph: 'screenshot'
        hotkey: 'ctrl+backspace'

    snaptogrid:
        fun: ->
            for elt in diagram.elements
                elt.x = elt.px = diagram.snap * Math.floor(elt.x / diagram.snap)
                elt.y = elt.py = diagram.snap * Math.floor(elt.y / diagram.snap)
            svg.tick()
        label: 'Snap to grid'
        glyph: 'magnet'
        hotkey: 'ctrl+space'

$ ->
   for name, command of commands
        button = d3.select('aside .btns')
            .append('button')
            .attr('title', "#{command.label} [#{command.hotkey}]")
            .attr('class', 'btn btn-default btn-sm')
            # .text(command.label)
            .on('click', command.fun)
        if command.glyph
            button
                .append('span')
                .attr('class', "glyphicon glyphicon-#{command.glyph}")
        Mousetrap.bind command.hotkey, command.fun


init_commands = ->
    taken_hotkeys = []
    $('aside .icons .specific').each(-> Mousetrap.unbind $(@).attr('data-hotkey'))
    $('aside .icons svg').remove()
    $('aside h3')
        .attr('id', diagram.constructor.name)
        .addClass('specific')
        .text(diagram.constructor.label)

    for e in diagram.types.elements
        i = 1
        key = e.name[0].toLowerCase()
        while i < e.length and key in taken_hotkeys
            key = e[i++].toLowerCase()

        taken_hotkeys.push(key)

        fun = ((elt) -> -> element_add(elt))(e)
        hotkey = "a #{key}"
        icon = new e(0, 0, e.name)
        svgicon = d3.select('aside .icons')
            .append('svg')
            .attr('class', 'icon specific draggable btn btn-default')
            .attr('title', "#{e.name} [#{hotkey}]")
            .attr('data-hotkey', hotkey)
            .on('mousedown', fun)

        path = svgicon.append('path')

        txt = svgicon
            .append('text')
            .text(e.name)

        icon.set_txt_bbox(txt.node().getBBox())
        path.attr('d', icon.path())
        txt
            .attr('x', icon.txt_x())
            .attr('y', icon.txt_y())

        margin = 3
        svgicon
            .attr('viewBox', "
                #{-icon.width() / 2 - margin}
                #{-icon.height() / 2 - margin}
                #{icon.width() + 2 * margin}
                #{icon.height() + 2 * margin}")
            .attr('width', icon.width())
            .attr('height', icon.height())
            .attr('preserveAspectRatio', 'xMidYMid Meet')
        Mousetrap.bind hotkey, fun
