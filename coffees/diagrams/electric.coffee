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



class Diagrams.Electric extends Diagram
    label: 'Electric Diagram'
    types: @init_types()

    constructor: ->
        super
        @linkstyle = new LinkStyles.Rectangular()
        @snap.a = 90

E = Diagrams.Electric::types.elements

class Electric extends Element
    @resizeable: false
    @rotationable: true

    anchor_list: ->
        attach_self [cardinal.W, cardinal.E], @

    base_height: ->
        20

    _base_width: ->
        20

    base_width: ->
        @_base_width() + 2 * @wire_margin()

    wire_margin: ->
        10

    txt_y: ->
        @height() / 2 + 3 * @margin.y

    txt_height: ->
        @base_height()

    txt_width: ->
        @base_width()


class E.Junction extends Electric
    @fill: 'fg'

    constructor: ->
        super
        @margin.x = 0
        @margin.y = 0
        @text = ''

    base_width: ->
        @_base_width() / 4

    base_height: ->
        super() / 4

    anchor_list: ->
        attach_self [cardinal.N, cardinal.S, cardinal.W, cardinal.E], @

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "M 0 #{-h2}
         A #{w2} #{h2} 0 0 1 0 #{h2}
         A #{w2} #{h2} 0 0 1 0 #{-h2}
            "

class E.Resistor extends Electric
    @fill: 'none'

    _base_width: ->
        super() * 3

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        lw2 = w2 - @wire_margin()
        path = "M #{-w2} 0
                L #{-lw2} 0"
        for w in [-3..2]
            path = "#{path} L #{lw2 * w / 3 + lw2 / 6} #{h2 * if w % 2 then -1 else 1}"
        "#{path}
         L #{lw2} 0
         L #{w2} 0"


class E.Diode extends Electric
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        lw2 = w2 - @wire_margin()
        "M #{-w2} 0
         L #{-lw2} 0
         M #{-lw2} #{-h2}
         L #{lw2} 0
         L #{lw2} #{-h2}
         L #{lw2} #{h2}
         L #{lw2} 0
         L #{-lw2} #{h2}
        z
         M #{lw2} 0
         L #{w2} 0
        "

class E.Battery extends Electric
    @fill: 'fg'

    _base_width: ->
        super() / 3

    base_height: ->
        super() * 2

    path: ->
        w2 = @width() / 2
        lw2 = w2 - @wire_margin()
        lw4 = lw2 / 2
        h2 = @height() / 2
        h4 = h2 / 2

        "M #{-w2} 0
         L #{-lw2} 0
         M #{-lw2} #{-h4}
         L #{-lw4} #{-h4}
         L #{-lw4} #{h4}
         L #{-lw2} #{h4}
         z
         M #{lw2} #{-h2}
         L #{lw2} #{h2}
         M #{lw2} 0
         L #{w2} 0
        "

class Transistor extends Electric

    constructor: ->
        super
        @anchors[cardinal.N] = =>
            x: @x + (@width() / 2 - @wire_margin()) * .6
            y: @y - @height() / 2

        @anchors[cardinal.S] = =>
            x: @x + (@width() / 2 - @wire_margin()) * .6
            y: @y + @height() / 2

    base_width: ->
        2 * @_base_width() + 2 * @wire_margin()

    base_height: ->
        2 * super() + 2 * @wire_margin()

    anchor_list: ->
        attach_self [cardinal.W, cardinal.N, cardinal.S], @

    wire_margin: ->
        super()

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        lw2 = w2 - @wire_margin()
        lh2 = h2 - @wire_margin()

        wI = lw2 / 4
        hI = lh2 * .6
        hv = hI / 2
        ww = lw2 * .6
        hw = lh2 * .8

        "
         M #{-w2} 0
         L #{-lw2} 0
         A #{lw2} #{lw2} 0 1 1 #{lw2} 0
         A #{lw2} #{lw2} 0 1 1 #{-lw2} 0
         L #{-wI} 0
         M #{-wI} #{-hI}
         L #{-wI} #{hI}

         M #{-wI} #{-hv}
         L #{ww} #{-hw}
         M #{ww} #{-hw}
         L #{ww} #{-h2}

         M #{-wI} #{hv}
         L #{ww} #{hw}
         L #{ww} #{h2}
        "

class E.PNPTransistor extends Transistor
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        lw2 = w2 - @wire_margin()
        lh2 = h2 - @wire_margin()

        ww = lw2 * .6
        hw = lh2 * .8

        wa = lw2 * .1
        ha = lh2 * .7

        wb = lw2 * .3
        hb = lh2 * .4

        "#{super()}
        M #{ww} #{-hw}
        L #{wa} #{-ha}
        M #{ww} #{-hw}
        L #{wb} #{-hb}
        "

class E.NPNTransistor extends Transistor
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        lw2 = w2 - @wire_margin()
        lh2 = h2 - @wire_margin()

        ww = lw2 * .6
        hw = lh2 * .8

        wa = lw2 * .1
        ha = lh2 * .7

        wb = lw2 * .3
        hb = lh2 * .4

        "#{super()}
        M #{ww} #{hw}
        L #{wa} #{ha}
        M #{ww} #{hw}
        L #{wb} #{hb}
        "

class Diagrams.Electric::types.links.Wire extends Link
