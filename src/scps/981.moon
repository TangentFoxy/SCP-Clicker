pop = require "lib.pop"

{ -- 20 SCP the director's cut
  trigger: {scp: 0.25}
  icon: "icons/salt-shaker.png"
  tooltip: "SCP-981 \"The Director's Cut\""
  apply: (element, build_only) ->
    element.clicked = (x, y, button) =>
      if button == pop.constants.right_mouse
        icons.scp_info element
}
