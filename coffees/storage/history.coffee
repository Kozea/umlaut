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
    if location.search == '?nocatch/'
        load(JSON.parse(LZString.decompressFromBase64(location.hash.slice(1))))
    else
        try
            load(JSON.parse(LZString.decompressFromBase64(location.hash.slice(1))))
        catch ex1
            # Compat
            try
                load(JSON.parse(decodeURIComponent(escape(atob(location.hash.slice(1))))))
            catch ex2
                window.diagram = new Diagrams.Dot()
                note = Diagrams.Dot::types.elements.Note
                link = Diagrams.Dot::types.links.Normal
                window.svg = new Svg()
                diagram.title = 'There was an error loading your diagram :('
                diagram.elements.push(e1 = new note(undefined, undefined, ex1.message))
                diagram.elements.push(e2 = new note(undefined, undefined, ex1.stack))
                diagram.elements.push(e21 = new note(undefined, undefined, ex2.message))
                diagram.elements.push(e22 = new note(undefined, undefined, ex2.stack))
                diagram.elements.push(e3 = new note(undefined, undefined, 'You can try to reload\nyour browser without cache'))
                diagram.elements.push(e4 = new note(undefined, undefined, 'Otherwise it may be that\n your diagram is not compatible\nwith this version'))
                diagram.links.push(new link(e2, e1))
                diagram.links.push(new link(e2, e3))
                diagram.links.push(new link(e2, e4))
                diagram.links.push(new link(e21, e1))
                diagram.links.push(new link(e22, e2))
                diagram.links.push(new link(e21, e22))
                diagram.start_force()

    if diagram.cls.name != $('aside h3').attr('id')
        init_commands()
        svg.resize()

    svg.sync()
