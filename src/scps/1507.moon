pop = require "lib.pop"
data = require "data"

{ -- 30 SCP pink flamingos
  trigger: {scp: 0.4}
  icon: "icons/flamingo.png"
  tooltip: "SCP-1507 \"Pink Flamingos\"\n${cash_rate} containment cost, ${research}"
  cash_rate: -3.2
  research: 4.2
  apply: (element, build_only) ->
    if build_only and data.cleared_randoms[31]
      element.data.cash_rate -= icons[31].cash_rate
    unless build_only
      data.cash_rate += element.data.cash_rate
      data.research += element.data.research
    element.clicked = (x, y, button) =>
      if button == pop.constants.right_mouse
        icons.scp_info element
}
