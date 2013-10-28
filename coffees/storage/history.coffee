history_pop = () ->
    $diagrams = $('#diagrams')
    $editor = $('#editor')
    if not location.hash
        return

    if not svg?
        $editor.removeClass('hidden')
        $diagrams.addClass('hidden')
        window.svg = new Svg()

    load(JSON.parse(atob(location.hash.slice(1))))

    init_commands()
    svg.resize()


    state.no_save = true
    svg.sync()
