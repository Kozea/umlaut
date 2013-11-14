dist = (o, t) ->
    Math.sqrt(Math.pow((t.x - o.x), 2) + Math.pow((t.y - o.y), 2))

rotate = (pos, a) ->
    rad = Math.PI * a / 180
    x: pos.x * Math.cos(rad) - pos.y * Math.sin(rad)
    y: pos.x * Math.sin(rad) + pos.y * Math.cos(rad)


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

angle_to_cardinal = (a) ->
    switch a
        when  45 < a <= 135 then 'E'
        when 135 < a <= 225 then 'S'
        when 225 < a <= 315 then 'W'
        else 'N'
