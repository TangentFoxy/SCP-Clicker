pop = require "lib.pop"
data = require "data"

{ -- 29 SCP many fingers, many toes
  trigger: {scp: 0.38}
  icon: "icons/fractal-hand.png"
  tooltip: "SCP-584 \"Many Fingers, Many Toes\"\n${cash_rate} containment cost, ${research_rate} while contained"
  cash_rate: -4.5
  research_rate: 1.25
  apply: (element, build_only) ->
    unless build_only
      data.cash_rate += element.data.cash_rate
      data.research_rate += element.data.research_rate
    element.clicked = (x, y, button) =>
      if button == pop.constants.right_mouse
        icons.scp_info element
}
