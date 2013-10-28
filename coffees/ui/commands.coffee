element_add = (type) =>
    free = state.freemode or d3.event?.type == 'click'
    if free
        x = y = undefined
    else
        x = state.mouse.x
        y = state.mouse.y
    nth = diagram.elements.filter((elt) -> elt instanceof type).length + 1
    new_elt = new type(x, y, "#{type.name} ##{nth}", not free)
    diagram.elements.push(new_elt)
    svg.sync()

commands =
    reorganize:
        fun: ->
            sel = if state.selection.length > 0 then state.selection else diagram.elements
            for elt in sel
                elt.fixed = false
            svg.sync()
        label: 'Reorganize'
        hotkey: 'r'

    link:
        fun: ->
            state.linking = []
            for elt in state.selection
                state.linking.push(new Link(elt, state.mouse))
            svg.sync()
        label: 'Link elements'
        hotkey: 'l'

    edit:
        fun: ->
            for elt in state.selection
                elt.text = prompt("Enter a name for #{elt.text}:", elt.text) or elt.text
            svg.sync()
        label: 'Edit element text'
        hotkey: 'e'


    select_all:
        fun: (e) ->
            state.selection = diagram.elements.slice()
            d3.selectAll('g.element').classed('selected', true)
            e?.preventDefault()

        label: 'Select all elements'
        hotkey: 'ctrl+a'

    save:
        fun: (e) ->
            save()
            e?.preventDefault()

        label: 'Save locally'
        hotkey: 'ctrl+s'

    load:
        fun: (e) ->
            load(localStorage.getItem('data') or '')
            svg.sync()
            e?.preventDefault()

        label: 'Load locally'
        hotkey: 'ctrl+l'

    undo:
        fun: (e) ->
            history.go(-1)
            e?.preventDefault()

        label: 'Undo'
        hotkey: 'ctrl+z'

    redo:
        fun: (e) ->
            history.go(1)
            e?.preventDefault()

        label: 'Redo'
        hotkey: 'ctrl+y'

    remove:
        fun: ->
            for elt in state.selection
                diagram.elements.splice(diagram.elements.indexOf(elt), 1)
                for lnk in diagram.links.slice()
                    if elt == lnk.source or elt == lnk.target
                        diagram.links.splice(diagram.links.indexOf(lnk), 1)
            state.selection = []
            d3.selectAll('g.element').classed('selected', false)
            svg.sync()
        label: 'Remove elements'
        hotkey: 'del'

    linkstyle:
        fun: ->
            state.linkstyle = switch state.linkstyle
                when 'curve' then 'diagonal'
                when 'diagonal' then 'rectangular'
                when 'rectangular' then 'curve'
            svg.tick()
        label: 'Change link style'
        hotkey: 'space'

    freemode:
        fun: ->
            for elt in diagram.elements
                elt.fixed = state.freemode
            if state.freemode
                force.stop()
            else
                svg.sync()
            state.freemode = not state.freemode
        label: 'Toggle free mode'
        hotkey: 'tab'

    recenter:
        fun: ->
            zoom.translate([0, 0])
            zoom.event(underlay_g)
        label: 'Recenter'
        hotkey: 'ctrl+home'

    defaultscale:
        fun: ->
            zoom.scale(1)
            zoom.event(underlay_g)
        label: 'Default zoom'
        hotkey: 'ctrl+0'

    defaultscale:
        fun: ->
            zoom.scale(1)
            zoom.translate([0, 0])
            zoom.event(underlay_g)
        label: 'Reset view'
        hotkey: 'ctrl+backspace'

    snaptogrid:
        fun: ->
            for elt in diagram.elements
                elt.x = elt.px = state.snap * Math.floor(elt.x / state.snap)
                elt.y = elt.py = state.snap * Math.floor(elt.y / state.snap)
            svg.tick()
        label: 'Snap to grid'
        hotkey: 'ctrl+space'


init_commands = ->
    taken_hotkeys = []
    commands['diagram'] = '---'

    for e in diagram.types.elements
        i = 1
        key = e.name[0].toLowerCase()
        while i < e.length and key in taken_hotkeys
            key = e[i++].toLowerCase()

        taken_hotkeys.push(key)

        commands[e.name] =
            ((elt) ->
                fun: ->
                    element_add elt
                label: elt.name
                hotkey: "a #{key}")(e)

    aside = d3.select('aside')
    aside.selectAll('*').remove()
    for name, command of commands
        if command is '---'
            aside
                .append('h3')
                .attr('id', diagram.constructor.name)
                .text(diagram.constructor.label)
        else
            aside
                .append('button')
                .attr('title', "#{command.label} [#{command.hotkey}]")
                .text(command.label)
                .on 'click', command.fun
            Mousetrap.bind command.hotkey, command.fun
