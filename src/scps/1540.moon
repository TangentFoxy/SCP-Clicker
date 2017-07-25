pop = require "lib.pop"
data = require "data"

{ -- 17 SCP failed werewolf
  trigger: {scp: 0.12}
  icon: "icons/werewolf.png"
  tooltip: "SCP-1540 \"Failed Werewolf\"\n${cash_rate} containment cost, ${research_rate} while contained"
  cash_rate: -3.2
  research_rate: 0.32
  apply: (element, build_only) ->
    unless build_only
      data.cash_rate += element.data.cash_rate
      data.research_rate += element.data.research_rate
    element.clicked = (x, y, button) =>
      if button == pop.constants.right_mouse
        icons.scp_info element
}
