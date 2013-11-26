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
            $('<td>').text((new (Diagrams._get(type))()).label),
            $('<td>')
                .append($('<a>').attr('href', "##{b64_diagram}").append($('<i>', class: 'glyphicon glyphicon-folder-open')))
                .append($('<a>').attr('href', "#").append($('<i>', class: 'glyphicon glyphicon-trash')).on('click', ((k) -> ->
                    localStorage.removeItem k
                    $(@).closest('tr').remove()
                    false)(key))))

    $('#diagrams tr.new').remove()
    for name, type of Diagrams
        if name.match(/^_/)
            continue
        diagram = new type()
        b64_diagram = diagram.hash()
        $tbody.append($tr = $('<tr>'))
        $tr.addClass('new').append(
            $('<td>').text('Create a new'),
            $('<td>').text(diagram.label),
            $('<td>').append($('<a>').attr('href', "##{b64_diagram}").append($('<i>', class: 'glyphicon glyphicon-file'))))

