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


$ =>
  if location.pathname.match /\/test\//
    return
  list_diagrams()

  $('.dot2umlaut').click(->
    location.hash = dot($(@).siblings('textarea.dot').val()))

  @addEventListener("popstate", history_pop)

  $('.color-box').spectrum
    showAlpha: true
    change: (color) ->
      $el = $ @
      $el.css 'background-color', color.toRgbString()
      fg = $el.hasClass 'fg'
      for node in diagram.selection
        if not node.attrs
          node.attrs = {}
        if fg
          node.attrs.color = color.toRgbString()
        else
          node.attrs.fillcolor = color.toRgbString()
      svg.sync()

  history_pop() if location.hash
