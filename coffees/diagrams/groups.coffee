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


class Group extends Element
    contains: (elt) ->
        w2 = @width() / 2
        h2 = @height() / 2

        @x - w2 < elt.x < @x + w2 and @y - h2 < elt.y < @y + h2

    txt_y: ->
        lines = @text.split('\n').length
        @margin.y - @height() / 2 + @_txt_bbox.height - (@_txt_bbox.height * (lines - 1) / lines)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2
        h2l = -h2 + @txt_height() + @margin.y
        "M #{-w2} #{-h2}
         L #{w2} #{-h2}
         L #{w2} #{h2l}
         L #{-w2} #{h2l}
         z
         M #{w2} #{h2l}
         L #{w2} #{h2}

         M #{-w2} #{h2l}
         L #{-w2} #{h2}

         M #{-w2} #{h2}
         L #{w2} #{h2}
        "
