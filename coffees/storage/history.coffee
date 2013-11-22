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
    try
        load(JSON.parse(LZString.decompressFromBase64(location.hash.slice(1))))
    catch ex1
        # Compat
        try
            load(JSON.parse(decodeURIComponent(escape(atob(location.hash.slice(1))))))
        catch ex2
            window.diagram = new DotDiagram()
            window.svg = new Svg()
            diagram.title = 'There was an error loading your diagram :('
            diagram.elements.push(e1 = new Note(undefined, undefined, ex1.message))
            diagram.elements.push(e2 = new Note(undefined, undefined, ex1.stack))
            diagram.elements.push(e21 = new Note(undefined, undefined, ex2.message))
            diagram.elements.push(e22 = new Note(undefined, undefined, ex2.stack))
            diagram.elements.push(e3 = new Note(undefined, undefined, 'You can try to reload\nyour browser without cache'))
            diagram.elements.push(e4 = new Note(undefined, undefined, 'Otherwise it may be that\n your diagram is not compatible\nwith this version'))
            diagram.links.push(new dotted(e2, e1))
            diagram.links.push(new dotted(e2, e3))
            diagram.links.push(new dotted(e2, e4))
            diagram.links.push(new dotted(e21, e1))
            diagram.links.push(new dotted(e22, e2))
            diagram.links.push(new dotted(e21, e22))
            diagram.start_force()

    if diagram.cls.name != $('aside h3').attr('id')
        init_commands()
        svg.resize()

    svg.sync()
