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


class Link extends Base
  @marker_start: new Markers.None(false, true)
  @marker_end: new Markers.None()
  @type: 'full'

  text_margin: 10

  constructor: (@source, @target, text) ->
    super
    @a1 = @a2 = 0
    @text =
      source: text?.source or ''
      target: text?.target or ''
    @color = null

  objectify: (elements=diagram.elements)->
    name: @constructor.name
    source: elements.indexOf(@source)
    target: elements.indexOf(@target)
    source_anchor: @source_anchor
    target_anchor: @target_anchor
    text: @text
    attrs: @attrs

  nearest: (pos) ->
    if dist(pos, @a1) < dist(pos, @a2) then @source else @target

  path: ->
    c1 = @source.pos()
    c2 = @target.pos()
    if null in [c1, c2] or undefined in [c1.x, c1.y, c2.x, c2.y]
      return 'M 0 0'

    d1 = +if @source_anchor? then @source_anchor else @source.direction(c2.x, c2.y)
    @a1 = @source.rotate(@source.anchors[d1]())

    d2 = +if @target_anchor? then @target_anchor else @target.direction(@a1.x, @a1.y)

    if @source == @target and d1 == d2
      d2 = +next(@target.anchors, d1.toString())

    @a2 = @target.rotate(@target.anchors[d2]())
    @o1 = d1 + @source._rotation
    @o2 = d2 + @target._rotation

    diagram.linkstyle.get(@source, @target, @a1, @a2, @o1, @o2)
