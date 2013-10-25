

history_pop = () ->
    try
        if location.hash
            load(atob(location.hash.slice(1)))
        else
             load(localStorage.getItem('data'))
    catch
        load(default_hash)

    state.no_save = true
    sync()

@addEventListener("popstate", history_pop)


# ff hack
if @mozInnerScreenX != null
    history_pop()
