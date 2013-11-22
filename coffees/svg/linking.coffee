LinkStyles = {}

class LinkStyle extends Base
    get: (source, target, a1, a2, o1, o2) ->
        "M #{a1.x} #{a1.y} L #{a2.x} #{a2.y}"

class LinkStyles.Diagonal extends LinkStyle

class LinkStyles.Rectangular extends LinkStyle
    get: (source, target, a1, a2, o1, o2) ->
        horizontal_1 = Math.abs(o1 % pi) < pi / 4
        horizontal_2 = Math.abs(o2 % pi) < pi / 4
        path = "M #{a1.x} #{a1.y} L"
        if not horizontal_1 and horizontal_2
               path = "#{path} #{a1.x} #{a2.y}"
           else if horizontal_1 and not horizontal_2
               path = "#{path} #{a2.x} #{a1.y}"
           else if horizontal_1 and horizontal_2
               mid = a1.x + .5 * (a2.x - a1.x)
               path = "#{path} #{mid} #{a1.y} L #{mid} #{a2.y}"
           else if not horizontal_1 and not horizontal_2
               mid = a1.y + .5 * (a2.y - a1.y)
               path = "#{path} #{a1.x} #{mid} L #{a2.x} #{mid}"
        "#{path} L #{a2.x} #{a2.y}"

class LinkStyles.Demicurve extends LinkStyle
    get: (source, target, a1, a2, o1, o2) ->
        horizontal_1 = Math.abs(o1 % pi) < pi / 4
        horizontal_2 = Math.abs(o2 % pi) < pi / 4
        path = "M #{a1.x} #{a1.y} C"
        m =
            x: .5 * (a1.x + a2.x)
            y: .5 * (a1.y + a2.y)

        if horizontal_1
            path = "#{path} #{m.x} #{a1.y}"
        else
            path = "#{path} #{a1.x} #{m.y}"

        if horizontal_2
            path = "#{path} #{m.x} #{a2.y}"
        else
            path = "#{path} #{a2.x} #{m.y}"
        "#{path} #{a2.x} #{a2.y}"

class LinkStyles.Curve extends LinkStyle
    get: (source, target, a1, a2, o1, o2) ->
        path = "M #{a1.x} #{a1.y} C"
        d = dist(a1, a2, o1, o2) / 2
        if source == target
            d *= 4
            if (o1 + o2) % pi == 0
                o1 -= pi / 4
                o2 += pi / 4

        dx =  Math.cos(o1) * d
        dy =  Math.sin(o1) * d
        path = "#{path} #{a1.x + dx} #{a1.y + dy}"

        dx =  Math.cos(o2) * d
        dy =  Math.sin(o2) * d
        path = "#{path} #{a2.x + dx} #{a2.y + dy}"
        "#{path} #{a2.x} #{a2.y}"

class LinkStyles.Rationalcurve extends LinkStyle
    get: (source, target, a1, a2, o1, o2) ->
        path = "M #{a1.x} #{a1.y} C"
        if source == target
            if (o1 + o2) % pi == 0
                o1 -= pi / 4
                o2 += pi / 4

        dx =  Math.cos(o1) * source.width()
        dy =  Math.sin(o1) * source.height()
        if source == target
            dx *= 4
            dy *= 4
        path = "#{path} #{a1.x + dx} #{a1.y + dy}"

        dx =  Math.cos(o2) * target.width()
        dy =  Math.sin(o2) * target.height()
        if source == target
            dx *= 4
            dy *= 4
        path = "#{path} #{a2.x + dx} #{a2.y + dy} #{a2.x} #{a2.y}"
