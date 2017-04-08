lume = require "lib.lume"

local data
data = {
  names: require "data.names"
  places: require "data.places"
  items: require "data.items"

  choose: (tbl) ->
    t = {}
    for key, value in pairs tbl
      t.key = value.chance or 0.01
    return tbl[lume.weightedchoice t]

  generate: (item) ->
    unless item
      item = {count: 0}
    {
      state: lume.randomchoice data.places.state
      country: lume.randomchoice data.places.country
      region: lume.randomchoice data.places.region
      small_int: lume.round lume.random 1, 7
      id: item.id
      sub_id: tostring(item.id) .. tostring 1 + lume.random item.count - 1
    }

  replace: (s, tab) ->
    tab = data.generate! unless tab
    (s\gsub('($%b{})', (w) -> tab[w\sub(3, -2)] or w))
}

return data
