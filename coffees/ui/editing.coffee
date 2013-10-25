

edit = (getter, setter) ->
    overlay = d3.select('#overlay')
        .classed('visible', true)
    textarea = overlay
        .select('textarea')
    textarea_node = textarea.node()
    textarea
        .on('input', ->
            setter(@value)
            sync()
        )
        .on('keydown', ->
            if d3.event.keyCode is 27
                textarea.on('input', null)
                textarea.on('keydown', null)
                textarea_node.value = ''
                overlay.classed('visible', false))
    textarea_node.value = getter()
    textarea_node.select()
    textarea_node.focus()
    overlay
        .on('click', ->
            if d3.event.target is @
                textarea.on('input', null)
                textarea.on('keydown', null)
                textarea_node.value = ''
                overlay.classed('visible', false))
