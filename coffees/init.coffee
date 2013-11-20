$ =>
    if location.pathname != '/'
        return
    list_diagrams()

    $('.dot2umlaut').click(->
        location.hash = dot($(@).siblings('textarea.dot').val()))

    @addEventListener("popstate", history_pop)
    # ff hack
    if location.hash and @mozInnerScreenX?
        history_pop()
