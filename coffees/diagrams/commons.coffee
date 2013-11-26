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


class Rect extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2} #{-h2}
         L #{w2} #{h2}
         L #{-w2} #{h2}
         z"

class Ellipsis extends Element
    txt_width: ->
        2 * super() / Math.sqrt(2)

    txt_height: ->
        2 * super() / Math.sqrt(2)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} 0
         A #{w2} #{h2} 0 1 1 #{w2} 0
         A #{w2} #{h2} 0 1 1 #{-w2} 0
        "

class Note extends Element
    shift: 15

    txt_width: ->
        super() + @shift

    txt_x: ->
        super() - @shift / 2

    txt_y: ->
        super()

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2 - @shift} #{-h2}
         L #{w2} #{-h2 + @shift}
         L #{w2} #{h2}
         L #{-w2} #{h2}
         L #{-w2} #{-h2 + @shift}
         z
         M #{w2} #{-h2 + @shift}
         L #{w2 - @shift} #{-h2 + @shift}
         L #{w2 - @shift} #{-h2}
        "

class Lozenge extends Element
    txt_width: ->
        ow = super()
        ow + Math.sqrt(ow * @super('txt_height', Lozenge))

    txt_height: ->
        oh = super()
        oh + Math.sqrt(oh * @super('txt_width', Lozenge))

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "M #{-w2} 0
         L 0 #{-h2}
         L #{w2} 0
         L 0 #{h2}
         z"

class Triangle extends Element
    txt_width: ->
        super() * 2

    txt_height: ->
        super() * 2

    txt_y: ->
        super() + @txt_height() / 4

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        "M 0 #{-h2}
         L #{w2} #{h2}
         L #{-w2} #{h2}
         z"


class House extends Element
    shift: 1.5
    constructor: ->
        super
        @anchors[cardinal.N] = =>
            x: @x
            y: @y - 3 * @shift_height() / 2

        @anchors[cardinal.W] = =>
            x: @x - @width() / 2
            y: @y + @shift_height() / 2

        @anchors[cardinal.E] = =>
            x: @x + @width() / 2
            y: @y + @shift_height() / 2

    shift_height: ->
        @height() * (@shift - 1) / @shift

    txt_height: ->
        super() * @shift

    txt_y: ->
        super() + @shift_height() / 2

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        th2 = h2 - @shift_height()

        "M #{-w2} #{-th2}
          L 0 #{-h2}
          L #{w2} #{-th2}
          L #{w2} #{h2}
          L #{-w2} #{h2}
          z"

class Association extends Link
    @marker: new BlackArrow()

class Inheritance extends Link
    @marker: new WhiteArrow()

class Composition extends Link
    @marker: new BlackDiamond()

class Comment extends Link
    @marker: new Arrow()
    @type: 'dashed'

class Aggregation extends Link
    @marker: new WhiteDiamond()
