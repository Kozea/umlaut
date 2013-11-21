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


order = (a, b) -> d3.ascending(a.ts, b.ts)

node_add = (type) =>
    x = diagram.mouse.x
    y = diagram.mouse.y

    if new type() instanceof Group
        set = diagram.groups
        diagram.last_types.group = type
    else
        set = diagram.elements
        diagram.last_types.element = type

    nth = set.filter((node) -> node instanceof type).length + 1
    new_node = new type(x, y, "#{type.name} ##{nth}", not diagram.force)
    set.push(new_node)
    if d3.event
        diagram.selection = [new_node]

    svg.sync(true)

    if d3.event
        # Hack to trigger d3 drag event on newly created element
        dom_node = null
        svg.svg.selectAll('g.node').each((node) ->
            if node == new_node
                dom_node = @)
        mouse_evt = document.createEvent('MouseEvent')
        mouse_evt.initMouseEvent(
            d3.event.type, d3.event.canBubble, d3.event.cancelable, d3.event.view,
            d3.event.detail, d3.event.screenX, d3.event.screenY, d3.event.clientX, d3.event.clientY,
            d3.event.ctrlKey, d3.event.altKey, d3.event.shiftKey, d3.event.metaKey,
            d3.event.button, d3.event.relatedTarget)
        dom_node.dispatchEvent(mouse_evt)


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
            svg.sync(true)
            save()
            e?.preventDefault()

        label: 'Save locally'
        glyph: 'save'
        hotkey: 'ctrl+s'

    edit:
        fun: ->
            edit((->
                if diagram.selection.length == 1
                    diagram.selection[0].text
                else
                    ''), ((txt) ->
                for node in diagram.selection
                    node.text = txt))
        label: 'Edit elements text'
        glyph: 'edit'
        hotkey: 'e'

    remove:
        fun: ->
            for node in diagram.selection
                if node in diagram.groups
                    diagram.groups.splice(diagram.groups.indexOf(node), 1)
                else if node in diagram.elements
                    diagram.elements.splice(diagram.elements.indexOf(node), 1)
                else if node in diagram.links
                    diagram.links.splice(diagram.links.indexOf(node), 1)
                for lnk in diagram.links.slice()
                    if node == lnk.source or node == lnk.target
                        diagram.links.splice(diagram.links.indexOf(lnk), 1)
            diagram.selection = []
            svg.sync(true)
        label: 'Remove elements'
        glyph: 'remove-sign'
        hotkey: 'del'

    select_all:
        fun: (e) ->
            diagram.selection = diagram.nodes().concat(diagram.links)
            svg.tick()
            e?.preventDefault()

        label: 'Select all elements'
        glyph: 'fullscreen'
        hotkey: 'ctrl+a'

    force:
        fun: (e) ->
            if diagram.force
                diagram.force.stop()
                diagram.force = null
                return
            diagram.start_force()
            e?.preventDefault()
        label: 'Toggle force'
        glyph: 'send'
        hotkey: 'tab'

    linkstyle:
        fun: ->
            diagram.linkstyle = switch diagram.linkstyle
                when 'curve' then 'diagonal'
                when 'diagonal' then 'rectangular'
                when 'rectangular' then 'demicurve'
                when 'demicurve' then 'curve'
            svg.tick()
        label: 'Change link style'
        glyph: 'retweet'
        hotkey: 'space'

    defaultscale:
        fun: ->
            svg.zoom.scale(1)
            svg.zoom.translate([0, 0])
            svg.zoom.event(d3.select('.background'))
        label: 'Reset view'
        glyph: 'screenshot'
        hotkey: 'ctrl+backspace'

    snaptogrid:
        fun: ->
            for node in diagram.nodes()
                node.x = node.px = diagram.snap.x * Math.floor(node.x / diagram.snap.x)
                node.y = node.py = diagram.snap.y * Math.floor(node.y / diagram.snap.y)
            svg.tick()
        label: 'Snap to grid'
        glyph: 'magnet'
        hotkey: 'ctrl+space'

    switch:
        fun: ->
            for node in diagram.selection
                if node instanceof Link
                    [node.source, node.target] = [node.target, node.source]
                if node instanceof Element
                    for link in diagram.links
                        [link.source, link.target] = [link.target, link.source]
            svg.tick()
        label: 'Switch link direction'
        glyph: 'transfer'
        hotkey: 'w'

$ ->
   for name, command of commands
        button = d3.select('.btns')
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
        .attr('id', diagram.cls.name)
        .addClass('specific')
        .text(diagram.label)

    for e in diagram.types.elements.concat(diagram.types.groups)
        i = 1
        key = e.name[0].toLowerCase()
        while i < e.length and key in taken_hotkeys
            key = e[i++].toLowerCase()

        taken_hotkeys.push(key)

        fun = ((node) -> -> node_add(node))(e)
        hotkey = "a #{key}"
        icon = new e(0, 0, e.name)
        if icon instanceof Group
            icon._height = 70
            icon._width = 90
        svgicon = d3.select('aside .icons')
            .append('svg')
            .attr('class', 'icon specific draggable btn btn-default')
            .attr('title', "#{e.name} [#{hotkey}]")
            .attr('data-hotkey', hotkey)
            .on('mousedown', fun)

        element = svgicon
            .selectAll(if icon instanceof Group then 'g.group' else 'g.element')
            .data([icon])

        element.enter()
            .call(enter_node)
        element
            .call(update_node)

        margin = 3
        svgicon
            .attr('viewBox', "
                #{-icon.width() / 2 - margin}
                #{-icon.height() / 2 - margin}
                #{icon.width() + 2 * margin}
                #{icon.height() + 2 * margin}")
            .attr('width', icon.width())
            .attr('height', icon.height())
            .attr('preserveAspectRatio', 'xMidYMid meet')
        Mousetrap.bind hotkey, fun

    taken_hotkeys = []
    for l, n in diagram.types.links
        i = 1
        key = l.name[0].toLowerCase()
        while i < l.length and key in taken_hotkeys
            key = l[i++].toLowerCase()

        taken_hotkeys.push(key)

        hotkey = "l #{key}"
        icon = new l(e1 = new Element(0, 0), e2 = new Element(100, 0))
        e1.set_txt_bbox(width: 10, height: 10)
        e2.set_txt_bbox(width: 10, height: 10)

        svgicon = d3.select('aside .icons')
            .append('svg')
            .attr('class', "icon specific btn btn-default link #{l.name}")
            .attr('title', "#{l.name} [#{hotkey}]")
            .attr('data-hotkey', hotkey)
            .classed('active', n == 0)
            .on('mousedown', ((lnk) ->
                ->
                    diagram.last_types.link = lnk
                    d3.selectAll('aside .icons .link').classed('active', false)
                    d3.select(@).classed('active', true)
                    )(l))

        link = svgicon
            .selectAll('g.link')
            .data([icon])

        link.enter().call(enter_link, false)
        link.call(update_link)
        link.call(tick_link)

        svgicon
            .attr('height', 20)
            .attr('viewBox', "0 -10 100 20")
            .attr('preserveAspectRatio', 'none')
        Mousetrap.bind hotkey, fun
