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


class Marker extends Base
    @fill: 'fg'
    @stroke: 'fg'

    constructor: ->
        super
        @id = @constructor.name

class Void extends Marker
    path: ->
        'M 0 0'

class Arrow extends Marker
    @fill: 'none'

    path: ->
        'M 10 0 L 20 5 L 10 10'

class BlackArrow extends Arrow
    @fill: 'fg'

    path: ->
        "#{super()} z"

class WhiteArrow extends BlackArrow
    @fill: 'bg'

class BlackDiamond extends Marker
    path: ->
        'M 0 5 L 10 0 L 20 5 L 10 10 z'

class WhiteDiamond extends BlackDiamond
    @fill: 'bg'

class BlackDot extends Marker
    path: ->
        'M 9 5 A 5 5 0 1 1 19 5 A 5 5 0 1 1 9 5'

class WhiteDot extends BlackDot
    @fill: 'bg'
