

edit = (elt) ->
    overlay = d3.select('#overlay')
        .classed('visible', true)
    textarea = overlay
        .select('textarea')
    textarea_node = textarea.node()
    textarea
        .on('input', ->
            elt.text = @value
            sync()
        )
        .on('keydown', ->
            if d3.event.keyCode is 27
                textarea.on('input', null)
                textarea.on('keydown', null)
                textarea_node.value = ''
                overlay.classed('visible', false))
    textarea_node.value = elt.text
    textarea_node.select()
    textarea_node.focus()
    overlay
        .on('click', ->
            if d3.event.target is @
                textarea.on('input', null)
                textarea.on('keydown', null)
                textarea_node.value = ''
                overlay.classed('visible', false))
