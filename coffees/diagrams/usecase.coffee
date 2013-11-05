class Case extends Ellipsis

class Actor extends Element
    stick: 10

    height: ->
        super() + 4 * @stick

    txt_y: ->
        @height() / 2 - @txt_height() + 2 * @margin.y

    path: ->
        bottom = @height() / 2 - @txt_height() + @margin.y

        "M #{-@stick} #{bottom}
         L 0 #{bottom - @stick}
         M #{@stick} #{bottom}
         L 0 #{bottom - @stick}
         M 0 #{bottom - @stick}
         L 0 #{bottom - 2 * @stick}
         M #{-@stick} #{bottom - 1.75 * @stick}
         L #{@stick} #{bottom - 2.25 * @stick}
         M 0 #{bottom - 2 * @stick}
         L 0 #{bottom - 3 * @stick}
         A #{.5 * @stick} #{.5 * @stick} 0 1 1 0 #{bottom - 4 * @stick}
         A #{.5 * @stick} #{.5 * @stick} 0 1 1 0 #{bottom - 3 * @stick}
         "


class System extends Group

class UseCase extends Diagram
    label: 'UML Use Case Diagram'

    constructor: ->
        super()

        @linkstyle = 'diagonal'
        @types =
            elements: [Actor, Case]
            groups: [System]
            links: uml_links


Diagram.diagrams['UseCase'] = UseCase
