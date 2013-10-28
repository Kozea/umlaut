$ =>
    list_diagrams()
    @svg = new Svg()

    @addEventListener("popstate", history_pop)
    # ff hack
    if location.hash and @mozInnerScreenX != null
        history_pop()
