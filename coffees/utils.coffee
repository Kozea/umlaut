pi = Math.PI

to_deg = (a) ->
    180 * a / pi

to_rad = (a) ->
    pi * a / 180

dist = (o, t) ->
    Math.sqrt(Math.pow((t.x - o.x), 2) + Math.pow((t.y - o.y), 2))

rotate = (pos, a) ->
    x: pos.x * Math.cos(a) - pos.y * Math.sin(a)
    y: pos.x * Math.sin(a) + pos.y * Math.cos(a)

mod2pi = (a) ->
    ((a % (2 * pi)) + 2 * pi) % (2 * pi)

atan2 = (y, x) ->
    mod2pi Math.atan2(y, x)

to_svg_angle = (a) ->
    to_deg mod2pi(a)

cardinal =
    N: 3 * pi / 2
    S: pi / 2
    W: pi
    E: 0

angle_to_cardinal = (a) ->
    if pi / 4 < a <= 3 * pi / 4
        return 'S'
    if 3 * pi / 4 < a <= 5 * pi / 4
        return 'W'
    if 5 * pi / 4 < a <= 7 * pi / 4
        return 'N'
    return 'E'

cardinal_to_direction = (c) ->
    switch c
        when 'N'
            x: 0
            y: -1
        when 'S'
            x: 0
            y: 1
        when 'W'
            x: -1
            y: 0
        when 'E'
            x: 1
            y: 0
        when 'SE'
            x: 1
            y: 1
        when 'SW'
            x: -1
            y: 1
        when 'NW'
            x: -1
            y: -1
        when 'NE'
            x: 1
            y: -1
