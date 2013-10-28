load = (data) =>
    Type = Diagram.diagrams[data.name]
    window.diagram = new Type()

    diagram.title = data.title

    for elt in data.elements
        element = diagram.element(elt.name)
        diagram.elements.push(new element(elt.x, elt.y, elt.text, elt.fixed))
    for lnk in data.links
        link = diagram.link(lnk.name)
        diagram.links.push(new link(diagram.elements[lnk.source], diagram.elements[lnk.target], lnk.text))

    state.selection = []

save = =>
    localStorage.setItem("#{diagram.constructor.name}|#{diagram.title}", diagram.hash())


generate_url = ->
    if state.no_save
        state.no_save = false
        return
    hash = '#' + diagram.hash()
    if location.hash != hash
        history.pushState(null, null, hash)
