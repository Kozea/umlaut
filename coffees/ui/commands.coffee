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


order = (a, b) -> d3.ascending(a.ts, b.ts)

node_add = (type, x, y) ->
  cls = diagram.types.elements[type]
  diagram.last_types.element = cls

  nth = diagram.elements.filter((node) -> node instanceof cls).length + 1
  new_node = new cls(x, y, "#{type} ##{nth}", not diagram.force)
  diagram.elements.push(new_node)
  if d3.event
    diagram.selection = [new_node]

  svg.sync(true)


remove = (nodes) ->
  for node in nodes
    if node in diagram.elements
      diagram.elements.splice(diagram.elements.indexOf(node), 1)
    else if node in diagram.links
      diagram.links.splice(diagram.links.indexOf(node), 1)

    for lnk in diagram.links.slice()
      if node == lnk.source or node == lnk.target
        diagram.links.splice(diagram.links.indexOf(lnk), 1)

clip =
  elements: []
  links: []

cut = ->
  copy()
  remove diagram.selection
  diagram.selection = []
  svg.sync true
  false

copy = ->
  clip.elements = []
  clip.links = []

  elts = []
  for node in diagram.selection
    if node in diagram.elements
      clip.elements.push node.objectify()
      elts.push node

  for node in diagram.selection
    if node in diagram.links
      if node.source in diagram.selection and node.target in diagram.selection
        clip.links.push node.objectify(elts)
  false

paste = ->
  elts = []
  diagram.selection = []
  if not diagram.force
    shift =
      x: Math.round(50 * (Math.random() * 2 - 1))
      y: Math.round(50 * (Math.random() * 2 - 1))
  else
    shift = x: 0, y: 0


  for node in clip.elements
    elt = diagram.elementify node
    elt.x += shift.x
    elt.y += shift.y
    diagram.elements.push elt
    elts.push elt
    diagram.selection.push elt

  for node in clip.links
    link = diagram.linkify(node, elts)
    diagram.links.push link
    diagram.selection.push link

  svg.sync true
  false

last_command =
  fun: null
  args: null

wrap = (fun) ->
  ->
    if $('#overlay').hasClass('visible')
      $('#overlay').click() if arguments[1] is 'esc'
      return
    last_command =
      fun: fun
      args: arguments
    fun.apply @, arguments


commands =
  undo:
    fun: (e) ->
      history.go(-1)
      e?.preventDefault()

    label: 'Undo'
    glyph: 'chevron-left'
    hotkey: 'ctrl+z'

  redo:
    fun: (e) ->
      history.go(1)
      e?.preventDefault()

    label: 'Redo'
    glyph: 'chevron-right'
    hotkey: 'ctrl+y'

  save:
    fun: (e) ->
      svg.sync(true)
      save()
      e?.preventDefault()

    label: 'Save locally'
    glyph: 'save'
    hotkey: 'ctrl+s'

  export:
    fun: (e) ->
      svgout = diagram.to_svg()
      $('body').append(
        $a = $('<a>', {
          href: URL.createObjectURL(new Blob([svgout], type: 'image/svg+xml')),
          download: "#{diagram.title}.svg"
        }))
      $a[0].click()
      $a.remove()
    label: 'Export to svg'
    glyph: 'export'
    hotkey: 'ctrl+enter'

  export_to_textile:
    fun: (e) ->
      edit((-> "!data:image/svg+xml;base64,#{btoa(diagram.to_svg())}!:\
        http://kozea.github.io/umlaut/#{location.hash}"), (-> null))
    hotkey: 'ctrl+b'

  export_to_markdown:
    fun: (e) ->
      edit((-> "[![#{diagram.title}][#{diagram.title} - base64]]\
        [#{diagram.title} - umlaut_url]\n\n[#{diagram.title} - base64]:
        data:image/svg+xml;base64,#{btoa(diagram.to_svg())}\n\
        [#{diagram.title} - umlaut_url]:
        http://kozea.github.io/umlaut/#{location.hash}"), (-> null))
      e.preventDefault()
    hotkey: 'ctrl+m ctrl+d'

  edit:
    fun: ->
      edit((->
        if diagram.selection.length == 1
          e = diagram.selection[0]
          return [e.text, e.attrs?.color, e.attrs?.fillcolor]
        else
          return ['', '#ffffff', '#000000']), ((txt) ->
        for node in diagram.selection
          node.text = txt))
    label: 'Edit elements text'
    glyph: 'edit'
    hotkey: 'e'

  remove:
    fun: ->
      remove diagram.selection
      diagram.selection = []
      svg.sync(true)
    label: 'Remove elements'
    glyph: 'remove-sign'
    hotkey: 'del'

  select_all:
    fun: (e) ->
      diagram.selection = diagram.elements.concat(diagram.links)
      svg.tick()
      e?.preventDefault()

    label: 'Select all elements'
    glyph: 'fullscreen'
    hotkey: 'ctrl+a'

  force:
    fun: (e) ->
      if diagram.force
        diagram.force.stop()
        diagram.force = null
        return
      diagram.start_force()
      e?.preventDefault()
    label: 'Toggle force'
    glyph: 'send'
    hotkey: 'tab'

  linkstyle:
    fun: ->
      diagram.linkstyle = new LinkStyles[next(
        LinkStyles, diagram.linkstyle.cls.name)]()
      svg.tick()
    label: 'Change link style'
    glyph: 'retweet'
    hotkey: 'space'

  defaultscale:
    fun: ->
      diagram.zoom.scale = 1
      diagram.zoom.translate = [0, 0]
      svg.sync(true)
    label: 'Reset view'
    glyph: 'screenshot'
    hotkey: 'ctrl+backspace'

  snaptogrid:
    fun: ->
      for node in diagram.elements
        node.x = node.px = diagram.snap.x * Math.floor(node.x / diagram.snap.x)
        node.y = node.py = diagram.snap.y * Math.floor(node.y / diagram.snap.y)
      svg.tick()
    label: 'Snap to grid'
    glyph: 'magnet'
    hotkey: 'ctrl+space'

  switch:
    fun: ->
      for node in diagram.selection
        if node instanceof Link
          [node.source, node.target] = [node.target, node.source]
        if node instanceof Element
          for link in diagram.links
            [link.source, link.target] = [link.target, link.source]
      svg.tick()
    label: 'Switch link direction'
    glyph: 'transfer'
    hotkey: 'w'

  cycle_start_marker:
    fun: ->
      for node in diagram.selection
        if node instanceof Link
          Markers._cycle(node, true)
        if node instanceof Element
          for link in diagram.links
            Markers._cycle(link, true)
      svg.sync(true)
    label: 'Cycle start marker'
    glyph: 'arrow-right'
    hotkey: 'm s'

  cycle_end_marker:
    fun: ->
      for node in diagram.selection
        if node instanceof Link
          Markers._cycle(node)
        if node instanceof Element
          for link in diagram.links
            Markers._cycle(link)
      svg.sync(true)
    label: 'Cycle end marker'
    glyph: 'arrow-left'
    hotkey: 'm e'

  back_to_list:
    fun: (e) ->
      if diagram.force
        diagram.force.stop()
      if diagram instanceof Diagrams.Dot
        $('textarea.dot').val(diagram.to_dot())
      location.href = '#'
    label: 'Go back to diagram list'
    glyph: 'list'
    hotkey: 'esc'

  # Workaround for firefox
  cut:
    fun: cut
    hotkey: 'ctrl+x'

  copy:
    fun: copy
    hotkey: 'ctrl+c'

  paste:
    fun: paste
    hotkey: 'ctrl+v'


$ ->
  for name, command of commands
    if command.glyph
      button = d3.select('.btns')
        .append('button')
        .attr('title', "#{command.label} [#{command.hotkey}]")
        .attr('class', 'btn btn-default btn-sm')
        .on('click', command.fun)
        .append('span')
        .attr('class', "glyphicon glyphicon-#{command.glyph}")
    Mousetrap.bind command.hotkey, wrap(command.fun)
  Mousetrap.bind 'z', -> last_command.fun.apply(@, last_command.args)

  $(window).on('cut', cut).on('copy', copy).on('paste', paste)

  $('.waterlogo').on('wheel', (e) ->
    if e.originalEvent.deltaY > 0
      history.go(-1)
    else
      history.go(1)
  )


init_commands = ->
  for conf, val of diagram.force_conf
    for way, inc of {increase: 1.1, decrease: 0.9}
      Mousetrap.bind "f #{conf[0]} #{if way == 'increase' then '+' else '-'}", (
        (c, i) ->
          wrap((e) ->
            if diagram.force
              diagram.force_conf[c] *= i
              diagram.force.stop()
            diagram.start_force()))(conf, inc)

  taken_hotkeys = []
  $('aside .icons .specific').each(-> Mousetrap.unbind $(@).attr('data-hotkey'))
  $('aside .icons svg').remove()
  $('aside h3')
    .attr('id', diagram.cls.name)
    .addClass('specific')
    .text(diagram.label)

  for name, cls of diagram.types.elements
    if cls.alias
      continue
    i = 1
    key = name[0].toLowerCase()
    while i < name.length and key in taken_hotkeys
      key = name[i++].toLowerCase()

    taken_hotkeys.push(key)

    fun = ((node) -> -> node_add(node))(cls)
    hotkey = "a #{key}"
    icon = new cls(0, 0, name)
    svgicon = d3.select('aside .icons')
      .append('svg')
      .attr('class', 'icon specific draggable btn btn-default')
      .attr('title', "#{name} [#{hotkey}]")
      .attr('data-hotkey', hotkey)
      .attr('data-type', name)
      .call(extern_drag)


    element = svgicon
      .selectAll('g.element')
      .data([icon])

    element.enter()
      .call(enter_node, false)
    element
      .call(update_node)

    margin = 3
    svgicon
      .attr('viewBox', "
        #{-icon.width() / 2 - margin}
        #{-icon.height() / 2 - margin}
        #{icon.width() + 2 * margin}
        #{icon.height() + 2 * margin}")
      .attr('width', icon.width())
      .attr('height', icon.height())
      .attr('preserveAspectRatio', 'xMidYMid meet')
    Mousetrap.bind hotkey, wrap(fun)

  taken_hotkeys = []
  first = true
  for name, cls of diagram.types.links
    i = 1
    key = name[0].toLowerCase()
    while i < name.length and key in taken_hotkeys
      key = name[i++].toLowerCase()

    taken_hotkeys.push(key)

    hotkey = "l #{key}"
    icon = new cls(e1 = new Element(0, 0), e2 = new Element(100, 0))
    e1.set_txt_bbox(width: 10, height: 10)
    e2.set_txt_bbox(width: 10, height: 10)

    fun = (lnk) ->
      ->
        diagram.last_types.link = lnk
        d3.selectAll('aside .icons .link').classed('active', false)
        d3.select(@).classed('active', true)


    svgicon = d3.select('aside .icons')
      .append('svg')
      .attr('class', "icon specific btn btn-default link #{name}")
      .attr('title', "#{name} [#{hotkey}]")
      .attr('data-hotkey', hotkey)
      .classed('active', first)
      .on('click', fun(cls))

    link = svgicon
      .selectAll('g.link')
      .data([icon])

    link.enter().call(enter_link, false)
    link.call(update_link)
    link.call(tick_link)

    svgicon
      .attr('height', 20)
      .attr('viewBox', "0 -10 100 20")
    Mousetrap.bind hotkey, wrap(fun)
    if first
      diagram.last_types.link = cls
      first = false
