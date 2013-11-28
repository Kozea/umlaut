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


# class RemoteStorage
#     getItem: (k, callback) ->
#         $.ajax
#           url: "http://api.openkeyval.org/#{k}",
#           dataType: "jsonp",
#           success: (v) -> callback(v, k)

#     setItem: (k, v) ->
#         im = new Image()
#         im.src = "http://api.openkeyval.org/store/?#{k}=#{v}"

# remoteStorage = new RemoteStorage()

load = (data) =>
    Type = Diagrams._get(data.name)
    window.diagram = new Type()
    window.svg = new Svg()
    diagram.loads data

save = =>
    localStorage.setItem("#{diagram.cls.name}|#{diagram.title}", diagram.hash())

# publish = (k, b64)=>
#     key = "umlaut_#{k.replace('|', '-_-')}"
#     remoteStorage.getItem('umlaut_key_list', (list) ->
#         list = JSON.parse(list)
#         if key not in list
#             list.push key
#         remoteStorage.setItem(key, b64)
#         remoteStorage.setItem('umlaut_key_list', JSON.stringify(list)))

generate_url = ->
    return unless location.hash

    hash = '#' + diagram.hash()
    if location.hash != hash
        history.pushState(null, null, hash)

