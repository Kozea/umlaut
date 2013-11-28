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


class RemoteStorage
    getItem: (k, callback) ->
        key = btoa(k).replace(/\=/g, '_')
        $.ajax
          url: "http://api.openkeyval.org/#{key}",
          dataType: "jsonp",
          success: (v) -> callback(v, k)

    setItem: (k, v, callback) ->
        key = btoa(k).replace(/\=/g, '_')
        # Hardcore cross domain post iframe hack
        iframe = document.createElement("iframe")
        document.body.appendChild(iframe)
        iframe.style.display = "none"
        iframe.contentWindow.name = key
        form = document.createElement("form")
        form.target = key
        form.action = "http://api.openkeyval.org/#{key}"
        form.method = "POST"
        input = document.createElement("input")
        input.type = "hidden"
        input.name = 'data'
        input.value = v
        form.appendChild(input)
        document.body.appendChild(form)
        iframe.onload = ->
            form.remove()
            iframe.remove()
            callback and callback(k, v)
        form.submit()

remoteStorage = new RemoteStorage()

load = (data) =>
    Type = Diagrams._get(data.name)
    window.diagram = new Type()
    window.svg = new Svg()
    diagram.loads data

save = =>
    localStorage.setItem("#{diagram.cls.name}|#{diagram.title}", diagram.hash())

publish = (k, b64, callback)=>
    key = "umlaut_#{k.replace('|', '-_-')}"
    remoteStorage.getItem('umlaut_key_list', (list) ->
        list = JSON.parse(list) or []
        if key not in list
            list.push key
        remoteStorage.setItem(key, b64, ->
            remoteStorage.setItem('umlaut_key_list', JSON.stringify(list), callback)))

generate_url = ->
    return unless location.hash

    hash = '#' + diagram.hash()
    if location.hash != hash
        history.pushState(null, null, hash)

