import graphics, mouse from love
import round from require "lib.lume"

pop = require "lib.pop"

data = {
  cash: 0
  research: 0
  danger: 0
}

icon_size = 128
margin = 8

debug = false

local tooltip_box, tooltip_text

love.load = ->
  graphics.setBackgroundColor 255, 255, 255, 255

  pop.load "gui"

  width = math.floor graphics.getWidth! / (icon_size + margin)
  if graphics.getWidth! % (icon_size + margin) < 8
    width -= 1

  height = math.floor graphics.getHeight! / (icon_size + margin)
  if graphics.getHeight! % (icon_size + margin) < 8
    height -= 1

  icon_alignment = pop.element({
    w: width * (icon_size + margin) + margin
    h: height * (icon_size + margin) + margin
  })\align "center"
  icon_alignment.data.update = true

  cash = pop.icon(icon_alignment, {
    w: icon_size, h: icon_size
    icon: "icons/banknote.png"
    tooltip: "Seek funding. (+$1 cash +0.01 danger)"
  })\move icon_size + margin*2, margin

  research = pop.icon(icon_alignment, {
    w: icon_size, h: icon_size
    icon: "icons/soap-experiment.png"
    tooltip: "Research contained SCPs. (+1 research +0.5 danger)"
  })\move margin, margin

  cash.clicked = =>
    data.cash += 1
    data.danger += 0.01

  research.clicked = ->
    data.research += 1
    data.danger += 0.5

  cash.data.update = true
  research.data.update = true

  cash.update = (dt) =>
    data.cash += 0.1 * dt

  research.update = (dt) =>
    data.research += 0.3 * dt

  danger = pop.element()
  danger.data.update = true
  danger.update = (dt) =>
    data.danger += 0.008 * dt

  cash_display = pop.text("Cash: $0", 20)\setColor(0, 0, 0, 255)\align "left", "bottom"
  research_display = pop.text("Research: 0", 20)\setColor(0, 0, 0, 255)\align "right", "bottom"
  danger_display = pop.text("Danger: 0%", 20)\setColor(0, 0, 0, 255)\align "center", "bottom"

  cash_display.data.update = true
  research_display.data.update = true
  danger_display.data.update = true

  format = (num) ->
    formatted = num
    while true
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
      if k==0 then
        break
    return formatted

  cash_display.update = =>
    cash_display\setText "Cash: $#{format string.format "%.2f", round data.cash, .01}"
    cash_display\move margin, -margin --temporary manual margin

  research_display.update = =>
    research_display\setText "Research: #{format string.format "%.2f", round data.research, .01}"
    research_display\move -margin, -margin --temporary manual margin

  danger_display.update = =>
    danger_display\setText "Danger: #{format string.format "%.2f", round data.danger, .01}%"
    danger_display\move nil, -margin -- temporary manual margin

  tooltip_box = pop.box()
  tooltip_text = pop.text(tooltip_box, 20)
  tooltip_box.mousemoved = (x, y, dx, dy) =>
    @move dx, dy

love.update = (dt) ->
  pop.update dt

  if pop.hovered
    if pop.hovered.data.tooltip
      tooltip_text\setText pop.hovered.data.tooltip
      w, h = tooltip_text\getSize!
      tooltip_box\setSize w + margin*2, h + margin*2
      x, y = mouse.getPosition!
      tooltip_box\move x + margin, y + margin
      if tooltip_box.data.x + tooltip_box.data.w > graphics.getWidth!
        tooltip_box\move -(tooltip_box.data.x + tooltip_box.data.w - graphics.getWidth!)
      if tooltip_box.data.y + tooltip_box.data.h > graphics.getHeight!
        tooltip_box\move nil, -(tooltip_box.data.y + tooltip_box.data.h - graphics.getHeight!)
      tooltip_text\align!
      tooltip_text\move margin, margin
    else
      tooltip_text\setText ""
      tooltip_box\setSize 0, 0
    pop.focused = tooltip_box
  --if pop.hovered
  --  tooltip\setText(pop.hovered.data.tooltip)\move mouse.getPosition!
  --  pop.focused = tooltip
  --else
  --  tooltip\setText ""
  --  pop.focused = false

love.draw = ->
  pop.draw!
  pop.debugDraw! if debug

love.mousemoved = (x, y, dx, dy) ->
  pop.mousemoved x, y, dx, dy

love.mousepressed = (x, y, button) ->
  pop.mousepressed x, y, button

love.mousereleased = (x, y, button) ->
  pop.mousereleased x, y, button

love.keypressed = (key) ->
  unless pop.keypressed key
    if key == "escape"
      love.event.quit!
    elseif key == "d"
      debug = not debug

love.keyreleased = (key) ->
  pop.keyreleased key

love.textinput = (text) ->
  pop.textinput text
