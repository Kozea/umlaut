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
    catch
        # Compat
        try
            load(JSON.parse(decodeURIComponent(escape(atob(location.hash.slice(1))))))
        catch
            console.log('Nope')

    if diagram.cls.name != $('aside h3').attr('id')
        init_commands()
        svg.resize()

    svg.sync()
