lume = require "lib.lume"

local data
data = {
  names: require "data.names"
  places: require "data.places"
  items: require "data.items"

  -- item from data list (based on chance value per item)
  choose: (tbl) ->
    t = {}
    for key, value in pairs tbl
      t[key] = value.chance or 0.01
    return tbl[lume.weightedchoice t]

  -- generates random data for reports on an item
  generate: (item) ->
    unless item
      item = {count: 0}
    {
      state: lume.randomchoice data.places.state
      country: lume.randomchoice data.places.country
      region: lume.randomchoice data.places.region
      small_int: lume.round lume.random 1, 7
      id: item.id
      sub_id: tostring(item.id) .. "-" .. tostring 1 + lume.random item.count - 1
    }

  -- tbl is an item, optional
  replace: (s, tbl) ->
    tbl = data.generate tbl
    (s\gsub('($%b{})', (w) -> tbl[w\sub(3, -2)] or w))
}

return data
