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

class Diagrams.Dot extends Diagram
    label: 'Dot diagram'
    types: @init_types()

    constructor: ->
        super
        @linkstyle = new LinkStyles.Curve()

    markers: ->
        markers = []
        for name, marker of Markers
            if name.indexOf('_') != 0
                markers.push(new marker())
                markers.push(new marker(true))
                markers.push(new marker(false, true))
                markers.push(new marker(true, true))
        markers

    to_dot: ->
        directed = false
        dot = "graph umlaut {\n"
        for element in diagram.elements
            dot = "#{dot}  \"#{element.text}\""
            attrs = []
            shape = element.cls.name.toLowerCase()
            if shape != 'ellipse'
                attrs.push "shape=#{shape}"
            if element.width() != element.txt_width()
                attrs.push "width=#{element.width() / element.txt_width()}"
            if element.height() != element.txt_height()
                attrs.push "height=#{element.height() / element.txt_height()}"

            if not diagram.force
                attrs.push "pos=\"#{element.x.toFixed()},#{element.y.toFixed()}#{if element.fixed then '!' else ''}\""

            for key, val of element.attrs
                if key not in ['shape', 'label']
                    attrs.push "#{key}=#{val}"
            if attrs.length
                dot = "#{dot}[#{attrs.join(',')}]"
            dot = "#{dot};\n"

        marker_to_dot = (m) ->
            name = m.cls.name.toLowerCase()
            if m.open
                "o#{name}"
            else
                name

        for link in diagram.links
            if not link.marker_end
                op = '--'  # Graph not directed
            else
                op = '->'  # Graph directed
                directed = true

            dot = "#{dot}  \"#{link.source.text}\" #{op} \"#{link.target.text}\""
            attrs = []
            if link.marker_start
                attrs.push "arrowhead=#{marker_to_dot(link.marker_start)}"
            if link.marker_end
                attrs.push "arrowtail=#{marker_to_dot(link.marker_end)}"

            if link.text.source
                attrs.push "taillabel=\"#{link.text.source}\""
            if link.text.target
                attrs.push "headlabel=\"#{link.text.target}\""

            for key, val of link.attrs
                if key not in ['arrowhead', 'arrowtail', 'headlabel', 'taillabel']
                    attrs.push "#{key}=#{val}"
            if attrs.length
                dot = "#{dot}[#{attrs.join(',')}]"
            dot = "#{dot};\n"

        dot = "#{dot}}"
        if directed
            dot = "di#{dot}"
        dot

E = Diagrams.Dot::types.elements
L = Diagrams.Dot::types.links

class E.Box extends Rect

class E.Polygon extends Polygon

class E.Ellipse extends Ellipsis

class E.Oval extends E.Ellipse
    @alias: true

class E.Circle extends E.Ellipse
    txt_height: ->
        Math.max(super(), @super('txt_width'))

    txt_width: ->
        Math.max(super(), @super('txt_height'))

class E.Point extends Element
    @fill: 'fg'

    constructor: ->
        super
        @margin.x = 0
        @margin.y = 0
        @text = ''

    txt_width: ->
        5

    txt_height: ->
        5

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "M 0 #{-h2}
         A #{w2} #{h2} 0 0 1 0 #{h2}
         A #{w2} #{h2} 0 0 1 0 #{-h2}
            "

class E.Egg extends E.Ellipse
    shift: 1.5

    constructor: ->
        super
        # Empiric magic number to fix later maybe
        magic = 1.051
        @anchors[cardinal.E] = =>
            x: @x + magic * @width() / (4 - @shift)
            y: @y + @height() / 8

        @anchors[cardinal.W] = =>
            x: @x - magic * @width() / (4 - @shift)
            y: @y + @height() / 8

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M 0 #{-h2}
         C #{w2 / @shift} #{-h2} #{w2 * @shift} #{h2} 0 #{h2}
         C #{-w2 * @shift} #{h2} #{-w2 / @shift} #{-h2} 0 #{-h2}
        "


class E.Triangle extends Triangle

class E.Plaintext extends Element

    path: ->
        "M 0 0"

class E.Diamond extends Lozenge

class E.Trapezium extends Trapezium

class E.Parallelogram extends Parallelogram

class E.House extends House

class E.Pentagon extends Pentagon

class E.Hexagon extends Hexagon

class E.Septagon extends Septagon

class E.Octogon extends Octogon

class E.Rect extends E.Box
    @alias: true

class E.Rectangle extends E.Box
    @alias: true

class E.Square extends E.Box
    txt_height: ->
        Math.max(super(), @super('txt_width'))

    txt_width: ->
        Math.max(super(), @super('txt_height'))

class E.Star extends Star

class E.None extends E.Plaintext
    @alias: true

class E.Underline extends Element

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{h2}
         L #{w2} #{h2}
        "

class E.Note extends Note

for n, t of E
    t.rotationable = true

class L.Link extends Link
