history_pop = () ->
    $diagrams = $('#diagrams')
    $editor = $('#editor')

    if not location.hash
        $diagrams.removeClass('hidden')
        $editor.addClass('hidden')
        list_diagrams()
        return
    else
        $editor.removeClass('hidden')
        $diagrams.addClass('hidden')

    load(JSON.parse(atob(location.hash.slice(1))))
    if diagram.constructor.name != $('aside h3').attr('id')
        init_commands()
        svg.resize()
    state.no_save = true
    svg.sync()
