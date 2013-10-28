$ =>
    $diagrams = $('#diagrams')
    $editor = $('#editor')

    $tbody = $diagrams.find('tbody')
    for key, b64_diagram of localStorage
        [type, title] = key.split('|')
        $tbody.append($tr = $('<tr>'))
        $tr.append(
            $('<td>').text(title),
            $('<td>').text(@[type].label),
            $('<td>').text($('<a>').attr('href', "##{b64_diagram}")))

    @addEventListener("popstate", history_pop)
    # ff hack
    if location.hash and @mozInnerScreenX != null
        history_pop()
