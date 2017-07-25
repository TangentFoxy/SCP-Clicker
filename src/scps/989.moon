pop = require "lib.pop"

{ -- 19 SCP self-defense sugar
  trigger: {scp: 0.25}
  icon: "icons/amphora.png"
  tooltip: "SCP-989 \"Self-Defense Sugar\""
  apply: (element, build_only) ->
    element.clicked = (x, y, button) =>
      if button == pop.constants.right_mouse
        icons.scp_info element
}
