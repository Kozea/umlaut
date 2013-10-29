class Case extends Element
    width: ->
        2 * super() / Math.sqrt(2)

    height: ->
        2 * super() / Math.sqrt(2)

    path: ->
        w2 = @width() / 2
        h2 = @height() / 2

        "M #{-w2} 0
         A #{w2} #{h2} 0 1 1 #{w2} 0
         A #{w2} #{h2} 0 1 1 #{-w2} 0
        "

class Actor extends Element
    @stick: 10

    height: ->
        super() + 4 * Actor.stick

    txt_y: ->
        @height() / 2 - @txt_height()

    path: ->
        stick = Actor.stick
        bottom = @height() / 2 - @txt_height() - @margin.y

        "M #{-stick} #{bottom}
         L 0 #{bottom - stick}
         M #{stick} #{bottom}
         L 0 #{bottom - stick}
         M 0 #{bottom - stick}
         L 0 #{bottom - 2 * stick}
         M #{-stick} #{bottom - 2 * stick}
         L #{stick} #{bottom - 2 * stick}
         M 0 #{bottom - 2 * stick}
         L 0 #{bottom - 3 * stick}
         A #{.5 * stick} #{.5 * stick} 0 1 1 0 #{bottom - 4 * stick}
         A #{.5 * stick} #{.5 * stick} 0 1 1 0 #{bottom - 3 * stick}
         "


class Association extends Link


class UseCase extends Diagram
    @label: 'UML Use case'

    constructor: ->
        super

        @linkstyle = 'diagonal'
        @types =
            elements: [Actor, Case]
            links: [Arrow]

Diagram.diagrams['UseCase'] = UseCase
