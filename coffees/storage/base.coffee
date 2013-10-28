load = (data) =>
    Type = Diagram.diagrams[data.name]
    window.diagram = new Type()
    diagram.loads data

save = =>
    localStorage.setItem("#{diagram.constructor.name}|#{diagram.title}", diagram.hash())


generate_url = ->
    if diagram.no_save
        diagram.no_save = false
        return
    hash = '#' + diagram.hash()
    if location.hash != hash
        history.pushState(null, null, hash)

