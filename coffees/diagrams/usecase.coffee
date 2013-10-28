class Case extends Element
    width: ->
        ow = super()
        2 * ow / Math.sqrt(2)

    height: ->
        oh = super()
        2 * oh / Math.sqrt(2)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} 0
         A #{w2} #{h2} 0 1 1 #{w2} 0
         A #{w2} #{h2} 0 1 1 #{-w2} 0
        "

class Actor extends Element
    path: ->
        h2 = @height() / 2

        stick = 10

        "M #{-stick} #{-h2}
         L 0 #{-h2 - stick}
         L #{stick} #{-h2}
         M 0 #{-h2 - stick}
         L 0 #{-h2 - 2 * stick}
         M #{-stick} #{-h2 - 2 * stick}
         L #{stick} #{-h2 - 2 * stick}
         M 0 #{-h2 - 2 * stick}
         L 0 #{-h2 - 3 * stick}
         A #{.5 * stick} #{.5 * stick} 0 1 1 0 #{-h2 - 4 * stick}
         A #{.5 * stick} #{.5 * stick} 0 1 1 0 #{-h2 - 3 * stick}
         "


class Association extends Link


class UseCase extends Diagram
    @label: 'UML Use case'

    constructor: ->
        super
        @types =
            elements: [Actor, Case]
            links: [Arrow]

Diagram.diagrams['UseCase'] = UseCase
