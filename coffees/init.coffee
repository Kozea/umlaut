$ =>
    list_diagrams()

    @addEventListener("popstate", history_pop)
    # ff hack
    if location.hash and @mozInnerScreenX?
        history_pop()
