history_pop = () ->
    $diagrams = $('#diagrams')
    $editor = $('#editor')

    if not location.hash
        $diagrams.removeClass('hidden')
        $editor.addClass('hidden')
        list_diagrams()
        return

    $editor.removeClass('hidden')
    $diagrams.addClass('hidden')

    load(JSON.parse(atob(location.hash.slice(1))))

    if not svg?
        window.svg = new Svg()

    if diagram.constructor.name != $('aside h3').attr('id')
        init_commands()
        svg.resize()

    diagram.no_save = true
    svg.sync()
