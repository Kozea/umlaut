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


class Class extends Rect
    shift: 10

    height: ->
        super() + @shift * 2

    txt_y: ->
        super() - @shift

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "#{super()}
         M #{-w2} #{h2 - @shift}
         L #{w2} #{h2 - @shift}
         M #{-w2} #{h2 - 2 * @shift}
         L #{w2} #{h2 - 2 * @shift}
        "

class ClassDiagram extends Diagram
    label: 'UML Class Diagram'

    constructor: ->
        super

        @linkstyle = new LinkStyles.Diagonal()
        @types =
            elements: [Class].concat(uml_elements)
            groups: [System]
            links: uml_links


Diagram.diagrams['ClassDiagram'] = ClassDiagram
