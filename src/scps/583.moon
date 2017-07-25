pop = require "lib.pop"
data = require "data"

{ -- 28 SCP deathly video tape
  trigger: {scp: 0.4}
  icon: "icons/audio-cassette.png"
  tooltip: "SCP-583 \"Deathly Video Tape\"\n${cash_rate} containment cost, ${research}"
  cash_rate: -0.15
  research: 4
  apply: (element, build_only) ->
    unless build_only
      data.cash_rate += element.data.cash_rate
      data.research += element.data.research
    element.clicked = (x, y, button) =>
      if button == pop.constants.right_mouse
        icons.scp_info element
}
