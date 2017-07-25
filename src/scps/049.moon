pop = require "lib.pop"
data = require "data"

{ -- 13 SCP the plague doctor
  trigger: {scp: 0.10}
  icon: "icons/plague-doctor-profile.png"
  tooltip: "SCP-049 \"The Plague Doctor\"\n${cash_rate} containment cost, ${research_rate} while contained"
  cash_rate: -2.5
  research_rate: 0.1
  apply: (element, build_only) ->
    unless build_only
      data.cash_rate += element.data.cash_rate
      data.research_rate += element.data.research_rate
    element.clicked = (x, y, button) =>
      if button == pop.constants.right_mouse
        icons.scp_info element
}
