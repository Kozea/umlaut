load = (data) =>
    Type = Diagram.diagrams[data.name]
    window.diagram = new Type()
    window.svg = new Svg()
    try
        diagram.loads data
    catch e
        console.log e

save = =>
    localStorage.setItem("#{diagram.cls.name}|#{diagram.title}", diagram.hash())


generate_url = ->
    hash = '#' + diagram.hash()
    if location.hash != hash
        history.pushState(null, null, hash)

