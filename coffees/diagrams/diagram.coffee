class Diagram
    @diagrams: {}

    constructor: ->
        name = @.constructor.name
        @label = '?'
        @title = 'Untitled ' + name
        @types = {}
        @elements = []
        @links = []

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
        elements: @elements.map (elt) -> elt.objectify()
        links: @links.map (lnk) -> lnk.objectify()

    hash: ->
        btoa(JSON.stringify(@objectify()))
