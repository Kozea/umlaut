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


edit = (getter, setter) ->
    overlay = d3.select('#overlay')
        .classed('visible', true)
    textarea = overlay
        .select('textarea')
    textarea_node = textarea.node()
    textarea
        .on('input', ->
            setter((val or ' ' for val in @value.split('\n')).join('\n'))
            svg.sync()
        )
        .on('keydown', ->
            if d3.event.keyCode is 27
                textarea.on('input', null)
                textarea.on('keydown', null)
                textarea_node.value = ''
                overlay.classed('visible', false)
                svg.sync(true))
    [text, fg, bg] = getter()
    $('.color-box.fg').css 'background-color', fg or '#000000'
    $('.color-box.bg').css 'background-color', bg or '#ffffff'
    textarea_node.value = text
    textarea_node.select()
    textarea_node.focus()
    close = ->
        if d3.event.target is @
            textarea.on('input', null)
            textarea.on('keydown', null)
            textarea_node.value = ''
            overlay.classed('visible', false)
    overlay
        .on('click', close)
        .on('touchstart', close)

$ =>
    $('.color-box').colpick
        layout: 'hex'
        submit: 0
        onChange: (hsb, hex, rgb, el) ->
            $el = $ el
            $el.css 'background-color', "##{hex}"
            fg = $el.hasClass 'fg'
            for node in diagram.selection
                if not node.attrs
                    node.attrs = {}
                if fg
                    node.attrs.color = '#' + hex
                else
                    node.attrs.fillcolor = '#' + hex
            svg.sync()
