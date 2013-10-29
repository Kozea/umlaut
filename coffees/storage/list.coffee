list_diagrams = ->
    $tbody = $('#diagrams tbody')
    $tbody.find('.local').remove()
    for key, b64_diagram of localStorage
        [type, title] = key.split('|')
        if not title?
            continue
        $tbody.append($tr = $('<tr>'))
        $tr.addClass('local').append(
            $('<td>').text(title),
            $('<td>').text(Diagram.diagrams[type].label),
            $('<td>').append($('<a>').attr('href', "##{b64_diagram}").text('⬈')))

    $ul = $('#diagrams ul')
    $ul.children().remove()
    for name, type of Diagram.diagrams
        diagram = new type()
        b64_diagram = diagram.hash()
        $ul.append(
            $('<li>').append(
                $('<a>').attr('href', "##{b64_diagram}").text("New #{diagram.label}")))

