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


pi = Math.PI

to_deg = (a) ->
    180 * a / pi

to_rad = (a) ->
    pi * a / 180

dist = (o, t) ->
    Math.sqrt(Math.pow((t.x - o.x), 2) + Math.pow((t.y - o.y), 2))

rotate = (pos, a) ->
    x: pos.x * Math.cos(a) - pos.y * Math.sin(a)
    y: pos.x * Math.sin(a) + pos.y * Math.cos(a)

mod2pi = (a) ->
    ((a % (2 * pi)) + 2 * pi) % (2 * pi)

atan2 = (y, x) ->
    mod2pi Math.atan2(y, x)

to_svg_angle = (a) ->
    to_deg mod2pi(a)

cardinal =
    N: 3 * pi / 2
    S: pi / 2
    W: pi
    E: 0

angle_to_cardinal = (a) ->
    if pi / 4 < a <= 3 * pi / 4
        return 'S'
    if 3 * pi / 4 < a <= 5 * pi / 4
        return 'W'
    if 5 * pi / 4 < a <= 7 * pi / 4
        return 'N'
    return 'E'

cardinal_to_direction = (c) ->
    switch c
        when 'N'
            x: 0
            y: -1
        when 'S'
            x: 0
            y: 1
        when 'W'
            x: -1
            y: 0
        when 'E'
            x: 1
            y: 0
        when 'SE'
            x: 1
            y: 1
        when 'SW'
            x: -1
            y: 1
        when 'NW'
            x: -1
            y: -1
        when 'NE'
            x: 1
            y: -1

timestamp = ->
    new Date().getTime()
