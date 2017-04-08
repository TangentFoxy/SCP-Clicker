lume = require "lib.lume"

local data
data = {
  names: require "data.names"
  places: require "data.places"
  potential_items: require "data.items"
  items: {} -- where found items will be stored

  -- overwritten on save loading with appropriate values
  next_anomalous_object: 1
  next_scp: 1

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

  -- call whenever appropriate to generate a report
  findItem: ->
    local found_item -- used to access a previously found item or store a newly found item
    local report     -- report returned with new item
    local count      -- how many instances were recovered

    -- the data representing this item and its report(s)
    new_item = data.choose data.potential_items

    -- we need to determine if this is a repeat finding
    found_again = false
    for item in *data.items
      if new_item.internal_id == item.internal_id
        found_again = true
        found_item = item
        break

    -- check possible reports for requirements, and choose one
    if new_item.found
      reports = {}
      for report, report_data in pairs new_item.found
        --if report_data.requires
        --  if report_data.requires.count
        --    if found_again
        --      if found_item.count >= report_data.requires.count
        --        table.insert reports, report
        --else
        --  table.insert reports, report
        table.insert reports, report
      if #reports > 0
        report = lume.randomchoice reports
        -- make sure count is correct if we chose a report with more than one instance
        for the_report, report_data in pairs new_item.found
          if report == the_report
            if report_data.count
              count = report_data.count
              break

    -- add an addendum to the report if this is a repeat finding
    if found_again and new_item.found_again
      addendums = {}
      for addendum, addendum_data in pairs new_item.found_again
        if addendum_data.requires
          if addendum_data.requires.count
            if found_item.count >= addendum_data.requires.count
              table.insert addendums, addendum
        else
          table.insert addendums, addendum
      if #addendums > 0
        report ..= " #{lume.randomchoice addendums}"

    -- just in case we fail to make a report
    unless report
      report = "An anomalous object was discovered. Details unknown."

    report = data.replace report, found_item

    if found_again
      found_item.count += count or 1
    else
      -- we don't want to store the FULL data on this item, just what is important
      found_item = {
        id: "AO-#{data.next_anomalous_object}"
        count: count or 1
        name: new_item.name
        danger: new_item.danger
        internal_id: new_item.internal_id
      }
      data.next_anomalous_object += 1
      table.insert data.items, found_item

    return report, found_item
}

id = 0
for item in *data.potential_items
  item.internal_id = id
  id += 1

--TODO when loading a game, remove any instances NOT containing "multiple" flag so they can't be discovered again.
--TODO when loading, update the stored next_anomalous_object and next_scp values!

return data
