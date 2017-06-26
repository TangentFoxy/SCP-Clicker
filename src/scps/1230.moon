pop = require "lib.pop"
data = require "data"

{ -- 24 SCP book of dreams
  trigger: {scp: 0.30}
  icon: "icons/black-book.png"
  tooltip: "SCP-1230 \"Book of Dreams\"\n${cash_rate} containment cost"
  cash_rate: -0.02
  apply: (element, build_only) ->
    unless build_only
      data.cash_rate += element.data.cash_rate
    element.clicked = (x, y, button) =>
      if button == pop.constants.right_mouse
        icons.scp_info element
}
