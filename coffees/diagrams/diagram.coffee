class Diagram
    @diagrams: {}

    constructor: ->
        @title = 'Untitled ' + @constructor.label
        @linkstyle = 'rectangular'
        @zoom =
            scale: 1
            translate: [0, 0]

        @elements = []
        @links = []

        @snap = 25
        @freemode = false

        @types = {}
        @selection = []
        @linking = []
        @mouse = new Mouse(0, 0, '')
        @dragging = false
        @no_save = false

    element: (name) ->
        for elt in @types.elements
            if elt.name == name
                return elt

    link: (name) ->
        for lnk in @types.links
            if lnk.name == name
                return lnk

    objectify: ->
        name: @constructor.name
        title: @title
        linkstyle: @linkstyle
        zoom: @zoom
        freemode: @freemode
        elements: @elements.map (elt) -> elt.objectify()
        links: @links.map (lnk) -> lnk.objectify()

    hash: ->
        btoa(JSON.stringify(@objectify()))

    loads: (obj) ->
        if obj.title
            @title = obj.title
        if obj.linkstyle
            @linkstyle = obj.linkstyle
        if obj.zoom
            @zoom = obj.zoom
        if obj.freemode
            @freemode = obj.freemode

        for elt in obj.elements
            element = diagram.element(elt.name)
            diagram.elements.push(new element(elt.x, elt.y, elt.text, elt.fixed))

        for lnk in obj.links
            link = diagram.link(lnk.name)
            diagram.links.push(new link(diagram.elements[lnk.source], diagram.elements[lnk.target], lnk.text))
