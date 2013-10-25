

element_add = (type) =>
    free = state.freemode or d3.event?.type == 'click'
    if free
        x = y = undefined
    else
        x = state.mouse.x
        y = state.mouse.y
    Type = E[type]
    nth = data.elts.filter((elt) -> elt instanceof Type).length + 1
    new_elt = new Type(x, y, "#{type} ##{nth}", not free)
    data.elts.push(new_elt)
    for elt in state.selection
        data.lnks.push(new Link(elt, new_elt))
    sync()

commands =
    reorganize:
        fun: ->
            sel = if state.selection.length > 0 then state.selection else data.elts
            for elt in sel
                elt.fixed = false
            sync()
        label: 'Reorganize'
        hotkey: 'r'

    link:
        fun: ->
            state.linking = []
            for elt in state.selection
                state.linking.push(new Link(elt, state.mouse))
            sync()
        label: 'Link elements'
        hotkey: 'l'

    edit:
        fun: ->
            for elt in state.selection
                elt.text = prompt("Enter a name for #{elt.text}:", elt.text) or elt.text
            sync()
        label: 'Edit element text'
        hotkey: 'e'


    select_all:
        fun: (e) ->
            state.selection = data.elts.slice()
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
            sync()
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
                data.elts.splice(data.elts.indexOf(elt), 1)
                for lnk in data.lnks.slice()
                    if elt == lnk.source or elt == lnk.target
                        data.lnks.splice(data.lnks.indexOf(lnk), 1)
            state.selection = []
            d3.selectAll('g.element').classed('selected', false)
            sync()
        label: 'Remove elements'
        hotkey: 'del'

    linkstyle:
        fun: ->
            state.linkstyle = switch state.linkstyle
                when 'curve' then 'diagonal'
                when 'diagonal' then 'rectangular'
                when 'rectangular' then 'curve'
            tick()
        label: 'Change link style'
        hotkey: 'space'

    freemode:
        fun: ->
            for elt in data.elts
                elt.fixed = state.freemode
            if state.freemode
                force.stop()
            else
                sync()
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
            for elt in data.elts
                elt.x = elt.px = state.snap * Math.floor(elt.x / state.snap)
                elt.y = elt.py = state.snap * Math.floor(elt.y / state.snap)
            tick()
        label: 'Snap to grid'
        hotkey: 'ctrl+space'


taken_hotkeys = []
for e of E
    i = 1
    key = e[0].toLowerCase()
    while i < e.length and key in taken_hotkeys
        key = e[i++].toLowerCase()

    taken_hotkeys.push(key)

    commands[e] =
        ((elt) ->
            fun: ->
                element_add elt
            label: elt
            hotkey: "a #{key}")(e)

for name, command of commands
    d3.select('aside')
        .append('button')
        .attr('title', "#{command.label} [#{command.hotkey}]")
        .text(command.label)
        .on 'click', command.fun
    Mousetrap.bind command.hotkey, command.fun
