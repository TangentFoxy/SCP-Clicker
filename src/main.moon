import graphics, mouse from love
import round from require "lib.lume"

pop = require "lib.pop"
icons = require "icons"
data = require "data"

icon_size = 128
margin = 8

debug = false

local tooltip_box, tooltip_text, icon_grid

add_icon = (data) ->
  x = #icon_grid.data.child % icon_grid.data.grid_width
  y = math.floor #icon_grid.data.child / icon_grid.data.grid_width
  data.w = icon_size
  data.h = icon_size
  data.update = true
  data.activated = true
  data.apply pop.icon(icon_grid, data)\move x * (icon_size + margin) + margin, y * (icon_size + margin) + margin

love.load = ->
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

  data.cash += data.cash_rate * dt
  data.research += data.research_rate * dt
  data.danger += data.danger_rate * dt

  data.cash += data.cash * data.cash_multiplier * dt
  data.research += data.research * data.research_multiplier * dt
  data.danger += data.danger * data.danger_multiplier * dt

  if data.danger < 0
    data.danger = 0

  for icon in *icons
    unless icon.activated
      if icon.trigger.cash and data.cash >= icon.trigger.cash
        add_icon icon
      elseif icon.trigger.research and data.research >= icon.trigger.research
        add_icon icon
      elseif icon.trigger.danger and data.danger >= icon.trigger.danger
        add_icon icon

  if pop.hovered
    if pop.hovered.data.tooltip
      tooltip_text\setText icons.replace pop.hovered.data
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
      --TODO pause popup!
      love.event.quit!
    elseif key == "d"
      debug = not debug

love.keyreleased = (key) ->
  pop.keyreleased key

love.textinput = (text) ->
  pop.textinput text
