pop = require "lib.pop"
data = require "data"

{ -- 25 SCP the clockworks
  trigger: {scp: 0.15}
  icon: "icons/gear-hammer.png"
  tooltip: "SCP-914 \"The Clockworks\"\n${cash_rate} containment cost, ${research_rate} while contained, ${danger_rate}"
  cash_rate: -2
  research_rate: 0.6
  danger_rate: 0.02
  apply: (element, build_only) ->
    unless build_only
      data.cash_rate += element.data.cash_rate
      data.research_rate += element.data.research_rate
      data.danger_rate += element.data.danger_rate
    element.clicked = (x, y, button) =>
      if button == pop.constants.right_mouse
        icons.scp_info element
}
