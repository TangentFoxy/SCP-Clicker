import insert from table

return {
  split_newline: (str) ->
    t = {}
    for word in str\gmatch "[^\n]+"
        insert t, word
    return t
}
