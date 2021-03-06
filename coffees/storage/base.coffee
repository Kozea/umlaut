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


load = (data) ->
  Type = Diagrams._get(data.name)
  window.diagram = new Type()
  window.svg = new Svg()
  diagram.loads data

save = ->
  localStorage.setItem("#{diagram.cls.name}|#{diagram.title}", diagram.hash())

generate_url = ->
  return unless location.hash

  hash = '#' + diagram.hash()
  if location.hash != hash
    history.pushState(null, null, hash)

