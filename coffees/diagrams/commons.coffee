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


class Parallelogram extends Element
  constructor: ->
    super

    @anchors[cardinal.E] = =>
      x: @x + @width() / 2 - @height() / 4
      y: @y

    @anchors[cardinal.W] = =>
      x: @x - @width() / 2 + @height() / 4
      y: @y

  txt_width: ->
    super() + @height()

  path: ->
    w2 = (@width() - @height()) / 2
    h2 = @height() / 2
    lw2 = @width() / 2

    "M #{-lw2} #{-h2}
     L #{w2} #{-h2}
     L #{lw2} #{h2}
     L #{-w2} #{h2}
     z"

class Trapezium extends Parallelogram
  path: ->
    w2 = (@width() - @height()) / 2
    h2 = @height() / 2
    lw2 = @width() / 2

    "M #{-w2} #{-h2}
     L #{w2} #{-h2}
     L #{lw2} #{h2}
     L #{-lw2} #{h2}
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

class Polygon extends Element
  n: 4
  shift: pi / 4

  _x: (a) ->
    o = pi / @n
    w2 = @width() / 2
    r = w2 * (Math.cos(o) / (Math.cos((a + @shift) % (2 * o) - o) )) * Math.cos(a - pi / 2)

  _y: (a) ->
    o = pi / @n
    h2 = @height() / 2
    r = h2 * (Math.cos(o) / (Math.cos((a + @shift) % (2 * o) - o) )) * Math.sin(a - pi / 2)

  constructor: ->
    super
    @anchors[cardinal.N] = =>
      x: @x + @_x(0)
      y: @y + @_y(0)

    @anchors[cardinal.E] = =>
      x: @x + @_x(pi / 2)
      y: @y + @_y(pi / 2)

    @anchors[cardinal.S] = =>
      x: @x + @_x(pi)
      y: @y + @_y(pi)

    @anchors[cardinal.W] = =>
      x: @x + @_x(3 * pi / 2)
      y: @y + @_y(3 * pi / 2)

  txt_width: ->
    super() * 2

  txt_height: ->
    super() * 2

  path: ->
    w2 = @width() / 2
    h2 = @height() / 2
    angle = 2 * pi / @n
    path = ''
    for i in [0..@n]
      path = "#{path} #{if i == 0 then 'M' else 'L'}  #{w2 * Math.sin(i * angle + @shift)} #{-h2 * Math.cos(i * angle + @shift)}"
    "#{path} z"

class Triangle extends Polygon
  n: 3
  shift: 0

class Pentagon extends Polygon
  n: 5
  shift: 0

class Hexagon extends Polygon
  n: 6
  shift: pi / 6

class Septagon extends Polygon
  n: 7
  shift: 0

class Octogon extends Polygon
  n: 8
  shift: pi  / 8

class Star extends Pentagon

  txt_width: ->
    super() * 5 * pi / (6 * 1.25)

  txt_height: ->
    super() * 5 * pi / (6 * 1.25)

  path: ->
    angle = 2 * pi / @n
    w2 = @width() / 2
    h2 = @height() / 2
    magic = 5 * pi / 6
    lw2 = w2 / magic
    lh2 = h2 / magic

    path = "M 0 #{-h2}"
    for i in [0..@n]
      path = "#{path} L #{w2 * Math.sin(i * angle)} #{-h2 * Math.cos(i * angle)} L #{lw2 * Math.sin((i + .5) * angle)} #{-lh2 * Math.cos((i + .5) * angle)}"
    "#{path} z"


class Association extends Link
  @marker_end: new Markers.Normal()

class Inheritance extends Link
  @marker_end: new Markers.Normal(true)

class Composition extends Link
  @marker_end: new Markers.Diamond()

class Comment extends Link
  @marker_end: new Markers.Vee()
  @type: 'dashed'

class Aggregation extends Link
  @marker_end: new Markers.Diamond(true)
