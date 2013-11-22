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


class Element extends Base
    @handle_size: 10
    @resizeable: true
    @rotationable: false
    @fill: 'bg'
    @stroke: 'fg'

    constructor: (@x, @y, @text, @fixed=false) ->
        super
        @ts = timestamp()
        @margin = x: 10, y: 5
        @_width = null
        @_height = null
        @_rotation = 0
        @anchors = {}

        @anchors[cardinal.N] = =>
            x: @x
            y: @y - @height() / 2

        @anchors[cardinal.S] = =>
            x: @x
            y: @y + @height() / 2

        @anchors[cardinal.E] = =>
            x: @x + @width() / 2
            y: @y

        @anchors[cardinal.W] = =>
            x: @x - @width() / 2
            y: @y

        @handles =
            NE: =>
                x: @width() / 2
                y: - @height() / 2
            NW: =>
                x: - @width() / 2
                y: - @height() / 2
            SW: =>
                x: - @width() / 2
                y: @height() / 2
            SE: =>
                x: @width() / 2
                y: @height() / 2
            O: =>
                x: 0
                y: - @height() / 2

    rotate: (pos, direct=true) ->
        if undefined in [pos.x, pos.y]
            return null
        ang = if direct then @_rotation else 2 * pi - @_rotation
        normed =
            x: pos.x - @x
            y: pos.y - @y
        normed = rotate(normed, ang)
        normed.x += @x
        normed.y += @y
        normed

    anchor_list: ->
        [cardinal.N, cardinal.S, cardinal.W, cardinal.E]

    handle_list: ->
        l = []
        if @cls.resizeable
            l = l.concat(['NW', 'NE', 'SW', 'SE'])
        if @cls.rotationable
            l.push('O')
        l

    pos: ->
        @rotate(
            x: @x
            y: @y)

    set_txt_bbox: (bbox) ->
        @_txt_bbox = bbox

    txt_width: ->
        @_txt_bbox.width + 2 * @margin.x

    txt_height: ->
        @_txt_bbox.height + 2 * @margin.y

    txt_x: ->
        0

    txt_y: ->
        lines = @text.split('\n').length
        @margin.y - (@_txt_bbox.height * (lines - 1) / lines ) / 2

    width: (w=null) ->
        if w != null
            @_width = w
        Math.max(@_width or 0, @txt_width())

    height: (h=null) ->
        if h != null
            @_height = h
        Math.max(@_height or 0, @txt_height())

    direction: (x, y) ->
        pi2 = 2 * pi
        target = atan2(y - @y, x - @x)
        min_diff = Infinity
        for anchor, pos of @anchors
            deviation = target - (+anchor) - @_rotation
            diff = Math.min(
                Math.abs(deviation) % pi2,
                Math.abs(deviation - pi2) % pi2)
            if diff < min_diff
                min_diff = diff
                min_anchor = anchor
        +min_anchor

    in: (rect) ->
        rect.x < @x < rect.x + rect.width and rect.y < @y < rect.y + rect.height

    contains: ->
        false

    objectify: ->
        name: @constructor.name
        x: @x
        y: @y
        width: @_width
        height: @_height
        rotation: @_rotation
        text: @text
        fixed: @fixed


class Mouse extends Element
    width: -> 1
    height: -> 1
    weight: 1

    constructor: ->
        super
        @lasts = []
        for i in [0..5]
            @lasts.push x:0, y: 0

    dynamic_rotation: ->
        @_rotation = atan2(
            @lasts.map((e) -> e.y).reduce(((e, l) -> e + l), 0)
            @lasts.map((e) -> e.x).reduce(((e, l) -> e + l), 0))
