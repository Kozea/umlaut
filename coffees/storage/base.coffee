load = (data) =>
    Type = Diagram.diagrams[data.name]
    window.diagram = new Type()
    try
        diagram.loads data
    catch e
        console.log e
    window.svg = new Svg()

save = =>
    localStorage.setItem("#{diagram.cls.name}|#{diagram.title}", diagram.hash())


generate_url = ->
    hash = '#' + diagram.hash()
    if location.hash != hash
        history.pushState(null, null, hash)

