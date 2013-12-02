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


class Diagrams.FlowChart extends Diagram
    label: 'Flow Chart'
    types: @init_types()

E = Diagrams.FlowChart::types.elements

class E.Process extends Rect

class E.IO extends Parallelogram

class E.Terminator extends Element
    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        shift = Math.min(w2 / 2, h2 / 2)

        "M #{-w2 + shift} #{-h2}
         L #{w2 - shift} #{-h2}
         Q #{w2} #{-h2} #{w2} #{-h2 + shift}
         L #{w2} #{h2 - shift}
         Q #{w2} #{h2} #{w2 - shift} #{h2}
         L #{-w2 + shift} #{h2}
         Q #{-w2} #{h2} #{-w2} #{h2 - shift}
         L #{-w2} #{-h2 + shift}
         Q #{-w2} #{-h2} #{-w2 + shift} #{-h2}"

class E.Decision extends Lozenge

class E.Delay extends Element
    constructor: ->
        super

        @anchors[cardinal.N] = =>
            x: @x + @txt_x()
            y: @y - @height() / 2

        @anchors[cardinal.S] = =>
            x: @x + @txt_x()
            y: @y + @height() / 2

    txt_x: ->
        super() - @height() / 4 + @txt_height() / 6

    txt_width: ->
        Math.max(0, super() - @txt_height() / 3) + @height() / 2

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2 - h2} #{-h2}
         A #{h2} #{h2} 0 1 1 #{w2 - h2} #{h2}
         L #{-w2} #{h2}
         z"


class E.SubProcess extends E.Process
    shift: 1.2

    txt_width: ->
        super() * @shift

    shift_width: ->
        @width() * (@shift - 1) / @shift

    path: ->
        w2 = @width() / 2
        lw2 = w2 - @shift_width() / 2
        h2 = @height() / 2

        "#{super()}
         M #{-lw2} #{-h2}
         L #{-lw2} #{h2}
         M #{lw2} #{-h2}
         L #{lw2} #{h2}
        "

class E.Document extends Element
    txt_height: ->
        super() * 1.25

    txt_y: ->
        super() - @height() / 16

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} #{-h2}
         L #{w2} #{-h2}
         L #{w2} #{h2}
         Q #{w2 / 2} #{h2 / 2} 0 #{h2}
         T #{-w2} #{h2}
         z"


class E.Database extends Element
    txt_y: ->
        super() + @radius() / 2

    txt_height: ->
        super() + 20

    radius: ->
        Math.min((@height() - @super('txt_height')) / 4, @width() / 3)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        r = @radius()

        "M #{-w2} #{-h2 + r}
         A #{w2} #{r} 0 1 1 #{w2} #{-h2 + r}
         A #{w2} #{r} 0 1 1 #{-w2} #{-h2 + r}
         M #{w2} #{-h2 + r}
         L #{w2} #{h2 - r}
         A #{w2} #{r} 0 1 1 #{-w2} #{h2 - r}
         L #{-w2} #{-h2 + r}"


class E.HardDisk extends Element
    txt_x: ->
        super() - @radius() / 2

    txt_width: ->
        super() + 20

    radius: ->
        Math.min((@width() - @super('txt_width')) / 4, @height() / 3)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        r = @radius()

        "M #{w2 - r} #{h2}
         A #{r} #{h2} 0 1 1 #{w2 - r} #{-h2}
         A #{r} #{h2} 0 1 1 #{w2 - r} #{h2}
         L #{-w2 + r} #{h2}
         A #{r} #{h2} 0 1 1 #{-w2 + r} #{-h2}
         L #{w2 - r} #{-h2}
        "


class E.ManualInput extends Element
    shift: 2

    constructor: ->
        super
        @anchors[cardinal.N] = =>
            x: @x
            y: @y - @shift_height() / 2

        @anchors[cardinal.W] = =>
            x: @x - @width() / 2
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
          L #{w2} #{-h2}
          L #{w2} #{h2}
          L #{-w2} #{h2}
          z"

class E.Preparation extends Hexagon

class E.InternalStorage extends E.Process
    hshift: 1.5
    wshift: 1.1

    txt_x: ->
        super() + @shift_width() / 2

    txt_y: ->
        super() + @shift_height() / 2

    txt_width: ->
        super() * @wshift

    txt_height: ->
        super() * @hshift

    shift_width: ->
        @width() * (@wshift - 1) / @wshift

    shift_height: ->
        @height() * (@hshift - 1) / @hshift

    path: ->
        w2 = @width() / 2
        lw2 = w2 - @shift_width()
        h2 = @height() / 2
        lh2 = h2 - @shift_height()

        "#{super()}
         M #{-lw2} #{-h2}
         L #{-lw2} #{h2}
         M #{-w2} #{-lh2}
         L #{w2} #{-lh2}
        "

class Diagrams.FlowChart::types.links.Flow extends Link
    @marker_end: new Markers.Normal()

class Diagrams.FlowChart::types.groups.Container extends Group
