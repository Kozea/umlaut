class rectangle extends Rect
    @rotationable: true

class ellipsis extends Ellipsis
    @rotationable: true

class lozenge extends Lozenge
    @rotationable: true

class note extends Note
    @rotationable: true


class ShapeDiagram extends Diagram
    label: ' Shapes Diagram'

    constructor: ->
       super
       @types =
           elements: [rectangle, ellipsis, lozenge, note]
           groups: []
           links: uml_links

Diagram.diagrams['ShapeDiagram'] = ShapeDiagram
