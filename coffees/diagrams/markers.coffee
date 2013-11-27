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

Markers = {}

class Marker extends Base
    # 0, 0 is the connect point, everything is drawn in x negative
    margin: ->
        2

    width: ->
        20

    height: ->
        20

    viewbox: ->
        w = @width() + @margin()
        h = @height() + @margin()
        "#{-w} #{-h/2} #{w} #{h}"

    constructor: (@open=false)->
        super
        @id = @cls.name + if @open then 'Open' else ''

class Markers.None extends Marker
    path: ->
        'M 0 0'

class Markers.Vee extends Marker
    path: ->
        w = -@width()
        h = @height()
        lw = w / 3
        h2 = h / 2
        "M 0 0 L #{w} #{-h2} L #{lw} 0 L #{w} #{h2} z"

class Markers.Normal extends Marker
    path: ->
        w = -@width()
        h2 = @height() / 2
        "M 0 0 L #{w} #{-h2} L #{w} #{h2} z"

class Markers.Diamond extends Marker
    width: ->
        40

    path: ->
        w = -@width()
        w2 = w / 2
        h2 = @height() / 2
        "M 0 0 L #{w2} #{-h2} L #{w} 0 L #{w2} #{h2} z"

class Markers.Dot extends Marker
    path: ->
        w = -@width()
        w2 = w / 2
        h2 = @height() / 2

        "M 0 0
         A #{-w2} #{h2} 0 1 1 #{w} 0
         A #{-w2} #{h2} 0 1 1 0 0"

class Markers.Box extends Marker
    path: ->
        w = -@width()
        w2 = w / 2
        h2 = @height() / 2

        "M 0 #{-h2}
         L 0 #{h2}
         L #{w} #{h2}
         L #{w} #{-h2}
        z"

Markers._get = (type) ->
    open = false
    if type.indexOf('o') == 0
        type = type.slice(1)
        open = true

    type = capitalize(type.replace(/^Black/, ''))
    if type and type of Markers
        m = new Markers[type](open)
    else
        m = new Markers.None()
