pop = require "lib.pop"
data = require "data"

{ -- 27 SCP absolute best of the 5th dimension
  trigger: {random: 0.02/60}   -- 2% per minute
  icon: "icons/compact-disc.png"
  tooltip: "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n0/3125 disks researched, ${cash} research cost, ${research}, ${danger}\n(click to research)"
  cash: -15
  research: 10
  danger: 2.5
  apply: (element, build_only) ->
    if data.scp092_researched_count == 3125
      element.data.tooltip = "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n3125/3125 disks researched"
    else
      element.data.tooltip = "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n#{data.scp092_researched_count}/3125 disks researched, ${cash} research cost, ${research}\n(click to research)"
    update_cash = ->
      --icons[27].cash = -(1.05 * (data.scp092_researched_count + 625) ^ 0.65 + 1.05 ^ (data.scp092_researched_count / 25) - 55)
      icons[27].cash = -(1.05 * (data.scp092_researched_count + 625) ^ 0.75 + 1.1 ^ (data.scp092_researched_count / 25) - 55)
    update_cash!
    element.clicked = (x, y, button) =>
      if button == pop.constants.left_mouse
        if data.scp092_researched_count < 3124 and data.cash >= math.abs element.data.cash
          data.cash += element.data.cash
          data.research += element.data.research
          data.danger += element.data.danger
          data.scp092_researched_count += 1
          update_cash!
          if data.scp092_researched_count == 3125
            element.data.tooltip = "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n3125/3125 disks researched"
          else
            element.data.tooltip = "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n#{data.scp092_researched_count}/3125 disks researched, ${cash} research cost, ${research}\n(click to research)"
      elseif button == pop.constants.right_mouse
        icons.scp_info element
}
