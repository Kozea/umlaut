class Diagram extends Base
    @diagrams: {}

    constructor: ->
        super
        @title = 'Untitled ' + @label
        @linkstyle = 'rectangular'
        @zoom =
            scale: 1
            translate: [0, 0]

        @elements = []
        @links = []
        @groups = []

        @snap =
            x: 25
            y: 25
            a: 22.5

        @types = {}
        @selection = []
        @linking = []
        @last_types =
            link: null
            element: null
            group: null

        @mouse = new Mouse(0, 0, '')
        @dragging = false
        @groupping = false

    markers: ->
        markers = {}
        for type in @types.links
            markers[type.marker.id] = type.marker
        val for key, val of markers

    group: (name) ->
        for grp in @types.groups
            if grp.name == name
                return grp

    element: (name) ->
        for elt in @types.elements
            if elt.name == name
                return elt

    link: (name) ->
        for lnk in @types.links
            if lnk.name == name
                return lnk

    nodes: ->
        @elements.concat(@groups)

    objectify: ->
        name: @constructor.name
        title: @title
        linkstyle: @linkstyle
        zoom: @zoom
        elements: @elements.map (elt) -> elt.objectify()
        groups: @groups.map (grp) -> grp.objectify()
        links: @links.map (lnk) -> lnk.objectify()

    hash: ->
        btoa(unescape(encodeURIComponent(JSON.stringify(@objectify()))))

    loads: (obj) ->
        if obj.title
            @title = obj.title
        if obj.linkstyle
            @linkstyle = obj.linkstyle
        if obj.zoom
            @zoom = obj.zoom

        for grp in (obj.groups or [])
            group_type = @group(grp.name)
            group = new group_type(grp.x, grp.y, grp.text, false)
            group._width = grp.width or null
            group._height = grp.height or null
            group._rotation = grp.rotation or 0
            @groups.push(group)

        for elt in obj.elements
            element_type = @element(elt.name)
            element = new element_type(elt.x, elt.y, elt.text, false)
            element._width = elt.width or null
            element._height = elt.height or null
            element._rotation = elt.rotation or 0
            @elements.push(element)

        for lnk in obj.links
            link_type = @link(lnk.name)
            link = new link_type(@nodes()[lnk.source], @nodes()[lnk.target], lnk.text)
            link.source_anchor = lnk.source_anchor
            link.target_anchor = lnk.target_anchor
            @links.push(link)
