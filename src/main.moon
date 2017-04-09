import graphics, mouse from love
import round from require "lib.lume"

pop = require "lib.pop"

data = {
  cash: 0
  savings_rate: 0
  research: 0
  danger: 0
}

icon_size = 128
margin = 8

debug = false

local tooltip_box, tooltip_text, icon_grid

add_icon = (data) ->
  x = #icon_grid.data.child % icon_grid.data.grid_width
  y = math.floor #icon_grid.data.child / icon_grid.data.grid_width
  --data.x = x * (icon_size + margin) + margin
  --data.y = y * (icon_size + margin) + margin
  data.w = icon_size
  data.h = icon_size
  data.update = true
  --return pop.icon icon_grid, data
  return pop.icon(icon_grid, data)\move x * (icon_size + margin) + margin, y * (icon_size + margin) + margin

love.load = ->
  --graphics.setBackgroundColor 255, 255, 255, 255

  pop.load "gui"

  grid_width = math.floor graphics.getWidth! / (icon_size + margin)
  if graphics.getWidth! % (icon_size + margin) < 8
    grid_width -= 1

  grid_height = math.floor graphics.getHeight! / (icon_size + margin)
  if graphics.getHeight! % (icon_size + margin) < 8
    grid_height -= 1

  icon_grid = pop.box({
    w: grid_width * (icon_size + margin) + margin
    h: grid_height * (icon_size + margin) + margin
    :grid_width, :grid_height
    update: true
  })\setColor(255, 255, 255, 255)\align "center"

  cash = add_icon {
    icon: "icons/banknote.png"
    tooltip: "Get funds.\n+$100 cash, +1% danger"
  }

  cash.clicked = (x, y, button) =>
    if button == pop.constants.left_mouse
      data.cash += 100
      data.danger += 1

  cash.update = (dt) =>
    data.cash += data.savings_rate * dt

  research = add_icon {
    icon: "icons/soap-experiment.png"
    tooltip: "Research contained SCPs.\n+1 research, +10% danger"
  }

  research.clicked = (x, y, button) =>
    if button == pop.constants.left_mouse
      data.research += 1
      data.danger += 10

  --research.update = (dt) =>
  --  data.research += 0.3 * dt

  savings = add_icon {
    icon: "icons/piggy-bank.png"
    tooltip: "Open a savings account.\n-$1000 cash, +$1/s cash"
  }

  savings.clicked = (x, y, button) =>
    if button == pop.constants.left_mouse
      if data.cash >= 1000
        data.cash -= 1000
        data.savings_rate += 1

  cash_display = pop.text({fontSize: 20, update: true})\align "left", "bottom"
  research_display = pop.text({fontSize: 20, update: true})\align "right", "bottom"
  danger_display = pop.text({fontSize: 20, update: true})\align "center", "bottom"

  format_commas = (num) ->
    result = num
    while true
      result, k = string.gsub(result, "^(-?%d+)(%d%d%d)", "%1,%2")
      break if k==0
    return result

  cash_display.update = =>
    cash_display\setText "Cash: $#{format_commas string.format "%.2f", round data.cash, .01}"
    cash_display\move margin, -margin --temporary manual margin

  research_display.update = =>
    research_display\setText "Research: #{format_commas string.format "%.2f", round data.research, .01}"
    research_display\move -margin, -margin --temporary manual margin

  danger_display.update = =>
    danger_display\setText "Danger: #{format_commas string.format "%.2f", round data.danger, .01}%"
    danger_display\move nil, -margin -- temporary manual margin

  tooltip_box = pop.box()
  tooltip_text = pop.text(tooltip_box, 20)
  tooltip_box.mousemoved = (x, y, dx, dy) =>
    @move dx, dy

love.update = (dt) ->
  pop.update dt

  -- danger doubles every 10 seconds
  data.danger += data.danger/10 * dt

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
