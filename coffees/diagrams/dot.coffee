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


class rectangle extends Rect
    @rotationable: true

class ellipsis extends Ellipsis
    @rotationable: true

class lozenge extends Lozenge
    @rotationable: true

class note extends Note
    @rotationable: true


class bare_link extends Link

class arrow extends Link
    @marker: new Arrow()

class blackarrow extends Link
    @marker: new BlackArrow()

class whitearrow extends Link
    @marker: new WhiteArrow()

class blackdiamond extends Link
    @marker: new Diamond()

class whitediamond extends Link
    @marker: new WhiteDiamond()

class dotted extends Link
    @marker: new Arrow()
    @type: 'dashed'

class DotDiagram extends Diagram
    label: 'Dot diagram'

    constructor: ->
        super
        @linkstyle = 'curve'
        @types =
            elements: [rectangle, ellipsis, lozenge, note]
            groups: []
            links: [bare_link, arrow, blackarrow, whitearrow, blackdiamond, whitediamond, dotted]

Diagram.diagrams['DotDiagram'] = DotDiagram
