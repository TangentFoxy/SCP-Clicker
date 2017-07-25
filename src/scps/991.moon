pop = require "lib.pop"
data = require "data"

{ -- 16 SCP the syringe
  trigger: {scp: 0.08}
  icon: "icons/syringe-2.png"
  tooltip: "SCP-991 \"The Syringe\"\nCan be used effectively in interrogations.\n${research}, ${danger}, ${cash_rate} per Class D"
  research: -50
  danger: 10
  cash_rate: 0.08
  danger_rate: 0.0001
  apply: (element) ->
    element.data.class_d_count = data.class_d_count
    bg = pop.box(element)\align("left", "bottom")\setColor 255, 255, 255, 255
    fg = pop.text(bg, 20)\setColor 0, 0, 0, 255
    if data.syringe_usage
      fg\setText "ACTIVE"
    else
      fg\setText "INACTIVE"
    element.update = =>
      if data.syringe_usage
        difference = data.class_d_count - element.data.class_d_count
        if difference != 0
          data.cash_rate += element.data.cash_rate * data.class_d_count
          data.danger_rate += element.data.danger_rate * data.class_d_count
    element.clicked = (x, y, button) =>
      if button == pop.constants.left_mouse
        if data.syringe_usage or data.research >= math.abs element.data.research
          data.syringe_usage = not data.syringe_usage
          if data.syringe_usage
            data.research += element.data.research
            data.danger += element.data.danger
            data.cash_rate += element.data.cash_rate * data.class_d_count
            data.danger_rate += element.data.danger_rate * data.class_d_count
            fg\setText "ACTIVE"
            element.data.class_d_count = data.class_d_count
            element.data.update = true
          else
            data.cash_rate -= element.data.cash_rate * data.class_d_count
            data.danger_rate -= element.data.danger_rate * data.class_d_count
            fg\setText "INACTIVE"
            element.data.update = false
          bg\setSize fg\getSize!
      elseif button == pop.constants.right_mouse
        icons.scp_info element
    -- dunno why these are needed...
    bg\setSize fg\getSize!
    fg\align!
}
