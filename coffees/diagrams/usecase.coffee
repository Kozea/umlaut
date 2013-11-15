class Case extends Ellipsis

class Actor extends Element
    constructor: ->
        super

        @anchors[cardinal.E] = =>
            x: @x + (@width() - @super('txt_width')) / 2
            y: @y

        @anchors[cardinal.W] = =>
            x: @x - (@width() - @super('txt_width')) / 2
            y: @y

    txt_y: ->
        @height() / 2 - @super('txt_height') + 2 + @margin.y

    txt_height: ->
        super() + 50

    txt_width: ->
        super() + 25

    path: ->
        wstick = (@width() - @super('txt_width')) / 2
        hstick = (@height() - @super('txt_height')) / 4
        bottom = @txt_y() -  @margin.y

        "M #{-wstick} #{bottom}
         L 0 #{bottom - hstick}
         M #{wstick} #{bottom}
         L 0 #{bottom - hstick}
         M 0 #{bottom - hstick}
         L 0 #{bottom - 2 * hstick}
         M #{-wstick} #{bottom - 1.75 * hstick}
         L #{wstick} #{bottom - 2.25 * hstick}
         M 0 #{bottom - 2 * hstick}
         L 0 #{bottom - 3 * hstick}
         A #{.5 * wstick} #{.5 * hstick} 0 1 1 0 #{bottom - 4 * hstick}
         A #{.5 * wstick} #{.5 * hstick} 0 1 1 0 #{bottom - 3 * hstick}
         "


class System extends Group

class UseCase extends Diagram
    label: 'UML Use Case Diagram'

    constructor: ->
        super

        @linkstyle = 'diagonal'
        @types =
            elements: [Actor, Case]
            groups: [System]
            links: uml_links


Diagram.diagrams['UseCase'] = UseCase
