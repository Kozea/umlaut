class rectangle extends Rect
    @rotationable: true

class ellipsis extends Ellipsis
    @rotationable: true

class lozenge extends Lozenge
    @rotationable: true

class note extends Note
    @rotationable: true


class bare_link extends Link

class arrow extends Link
    @marker: new Arrow()

class blackarrow extends Link
    @marker: new BlackArrow()

class whitearrow extends Link
    @marker: new WhiteArrow()

class blackdiamond extends Link
    @marker: new Diamond()

class whitediamond extends Link
    @marker: new WhiteDiamond()

class dotted extends Link
    @marker: new Arrow()
    @type: 'dashed'

class ShapeDiagram extends Diagram
    label: ' Shapes Diagram'

    constructor: ->
        super
        @linkstyle = 'curve'
        @types =
            elements: [rectangle, ellipsis, lozenge, note]
            groups: []
            links: [bare_link, arrow, blackarrow, whitearrow, blackdiamond, whitediamond, dotted]

Diagram.diagrams['ShapeDiagram'] = ShapeDiagram
