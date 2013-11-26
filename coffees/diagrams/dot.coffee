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

E = Diagrams.Dot::types.elements
L = Diagrams.Dot::types.links

class E.Box extends Rect
    @rotationable: true

class E.Polygon extends Rect

class E.Ellipse extends Ellipsis
    @rotationable: true

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

        @anchors[cardinal.E] = =>
            x: @x + @width() / (4 - @shift)
            y: @y

        @anchors[cardinal.W] = =>
            x: @x - @width() / (4 - @shift)
            y: @y
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M 0 #{-h2}
         C #{w2 / @shift} #{-h2} #{w2 * @shift} #{h2} 0 #{h2}
         C #{-w2 * @shift} #{h2} #{-w2 / @shift} #{-h2} 0 #{-h2}
        "


class E.Triangle extends Triangle
    @rotationable: true

class E.Plaintext extends Element
    @rotationable: true

    path: ->
        "M 0 0"

class E.Diamond extends Lozenge
    @rotationable: true

# class E.Trapezium extends Rect
#     @rotationable: true

# class E.Parallelogram extends Rect
#     @rotationable: true


class E.House extends House
    @rotationable: true

class E.Rect extends E.Box
    @alias: true

class E.Rectangle extends E.Box
    @alias: true

class E.Square extends E.Box
    txt_height: ->
        Math.max(super(), @super('txt_width'))

    txt_width: ->
        Math.max(super(), @super('txt_height'))

class E.None extends E.Plaintext
    @alias: true

class E.Underline extends Element
    @rotationable: true

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{h2}
         L #{w2} #{h2}
        "

class E.Note extends Note
    @rotationable: true


class L.None extends Link

class L.Curve extends Link
    @marker: new Arrow()

class L.Normal extends Link
    @marker: new BlackArrow()

class L.Onormal extends Link
    @marker: new WhiteArrow()

class L.Diamond extends Link
    @marker: new BlackDiamond()

class L.Odiamond extends Link
    @marker: new WhiteDiamond()

class L.Dot extends Link
    @marker: new BlackDot()

class L.Odot extends Link
    @marker: new WhiteDot()
