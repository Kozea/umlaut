class Class extends Rect
    shift: 10

    height: ->
        super() + @shift * 2

    txt_y: ->
        super() - @shift

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "#{super()}
         M #{-w2} #{h2 - @shift}
         L #{w2} #{h2 - @shift}
         M #{-w2} #{h2 - 2 * @shift}
         L #{w2} #{h2 - 2 * @shift}
        "

class ClassDiagram extends Diagram
    label: 'UML Class Diagram'

    constructor: ->
        super()

        @linkstyle = 'diagonal'
        @types =
            elements: [Class].concat(uml_elements)
            groups: [System]
            links: uml_links


Diagram.diagrams['ClassDiagram'] = ClassDiagram
