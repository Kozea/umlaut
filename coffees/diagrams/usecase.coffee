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

class Diagrams.UseCase extends Diagram
  label: 'UML Use Case Diagram'
  types: @init_types()

  constructor: ->
    super
    @linkstyle = new LinkStyles.Diagonal()


class Diagrams.UseCase::types.elements.Case extends Ellipsis

class Diagrams.UseCase::types.elements.Actor extends Element
  constructor: ->
    super

    @anchors[cardinal.E] = =>
      x: @x + (@width() - @super('txt_width')) / 2
      y: @y

    @anchors[cardinal.W] = =>
      x: @x - (@width() - @super('txt_width')) / 2
      y: @y

  txt_y: ->
    @height() / 2 - @super('txt_height') + 2 + 4 * @margin.y

  txt_height: ->
    super() + 50

  txt_width: ->
    super() + 25

  path: ->
    wstick = (@width() - @super('txt_width')) / 2
    hstick = (@height() - @super('txt_height')) / 4
    bottom = @txt_y() - 4 * @margin.y

    "M #{-wstick} #{bottom}
     L 0 #{bottom - hstick}
     M #{wstick} #{bottom}
     L 0 #{bottom - hstick}
     M 0 #{bottom - hstick}
     L 0 #{bottom - 2 * hstick}
     M #{-wstick} #{bottom - 1.75 * hstick}
     L #{wstick} #{bottom - 2.25 * hstick}
     M 0 #{bottom - 2 * hstick}
     L 0 #{bottom - 3 * hstick}
     A #{.5 * wstick} #{.5 * hstick} 0 1 1 0 #{bottom - 4 * hstick}
     A #{.5 * wstick} #{.5 * hstick} 0 1 1 0 #{bottom - 3 * hstick}
     "


class Diagrams.UseCase::types.elements.System extends Group

class Diagrams.UseCase::types.links.Association extends Association
class Diagrams.UseCase::types.links.Inheritance extends Inheritance
class Diagrams.UseCase::types.links.Aggregation extends Aggregation
class Diagrams.UseCase::types.links.Composition extends Composition
class Diagrams.UseCase::types.links.Comment extends Comment
