version = "0.6.0"

math.randomseed(os.time())

import graphics, mouse from love
import round, random, serialize, deserialize, shuffle from require "lib.lume"

pop = require "lib.pop"
icons = require "icons"
data = require "data"
timers = require "timers"
state = require "state"

icon_size = 128
margin = 8

debug = false

local tooltip_box, tooltip_text, icon_grid, tip, paused_overlay, exit_action, version_display

deepcopy = (orig) ->
  orig_type = type(orig)
  local copy
  if orig_type == 'table'
    copy = {}
    for orig_key, orig_value in next, orig, nil
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  return copy

icons.add_icon = (icon, build_only) ->
  x = #icon_grid.data.child % icon_grid.data.grid_width
  y = math.floor #icon_grid.data.child / icon_grid.data.grid_width
  if icon.trigger.multiple
    icon = deepcopy icon
  icon.w = icon_size
  icon.h = icon_size
  if false != icon.apply(pop.icon(icon_grid, icon)\move(x * (icon_size + margin) + margin, y * (icon_size + margin) + margin), build_only)
    icon.activated = true -- make sure icons are only added once when triggered
    unless build_only
      if icon.id != 0 -- don't save the pause button!
        table.insert data.icons, icon.id
    if icon.tip
      if icon.tipOnce
        tip\setText icon.tip
        tip\move margin, -margin*5 - tip\getHeight!*2 -- manual margin
        icon.tipOnce = false
      elseif icon.tipOnce == nil
        tip\setText icon.tip
        tip\move margin, -margin*5 - tip\getHeight!*2 -- manual margin

icons.fix_order = ->
  x, y = margin, margin
  data.icons = {}
  for icon in *icon_grid.child
    unless icon.data.id == 0 -- don't save the pause button!
      table.insert data.icons, icon.data.id
    icon\setPosition x, y
    x += margin + icon_size
    if x > icon_grid.data.w - margin - icon_size
      x = margin
      y += margin + icon_size

load = ->
  if loaded_text = love.filesystem.read "save.txt"
    loaded_data = deserialize loaded_text
    for key, value in pairs loaded_data
      unless key == "version"
        data[key] = value

    -- if old version of save data loaded, fix it
    unless loaded_data.version
      for id in *data.cleared_scps
        icons.add_icon(icons[id], true)
        table.insert, data.icons, id
      loaded_data.version = 1
    if loaded_data.version == 1
      data.scp_count = #data.cleared_scps -- reset to approximately correct count
      tmp = {}
      for id in *data.cleared_scps
        tmp[id] = true
      data.cleared_scps = tmp
      tmp = {}
      for id in *data.cleared_randoms
        tmp[id] = true
      data.cleared_randoms = tmp
      loaded_data.version = 2

    -- apply loaded data
    for id in pairs data.cleared_scps
      unless icons[id].trigger.multiple
        icons[id].trigger.scp = nil
    for id in pairs data.cleared_randoms
      unless icons[id].trigger.multiple
        icons[id].trigger.random = nil
    for id in *data.icons
      icons.add_icon(icons[id], true)

game_over = (reason) ->
  overlay = pop.box({w: graphics.getWidth!, h: graphics.getHeight!})
  pop.text(overlay, "Game Over", 60)\align("center", "top")\move nil, 20
  pop.text(overlay, reason, 24)\align "center", "center"
  pop.text(overlay, "Click to restart.", 20)\align("center", "bottom")\move nil, -16
  overlay.clicked = (x, y, button) =>
    exit_action = "reset_data"
    love.event.quit "restart"
    --return true

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
  })\setColor(255, 255, 255, 255)\align "center"

  cash_display = pop.text({fontSize: 20, update: true})\align "left", "bottom"
  research_display = pop.text({fontSize: 20, update: true})\align "right", "bottom"
  danger_display = pop.text({fontSize: 20, update: true})\align "center", "bottom"

  cash_rate_display = pop.text({fontSize: 20, update: true})\align "left", "bottom"
  research_rate_display = pop.text({fontSize: 20, update: true})\align "right", "bottom"
  danger_rate_display = pop.text({fontSize: 20, update: true})\align "center", "bottom"

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

  cash_rate_display.update = =>
    value = data.cash_rate + math.min math.abs(data.cash) * data.cash_multiplier, 500
    if value < 0
      cash_rate_display\setText "-$#{format_commas string.format "%.2f", round math.abs(value), .01}/s"
    else
      cash_rate_display\setText "+$#{format_commas string.format "%.2f", round value, .01}/s"
    cash_rate_display\move margin, -margin*3 - cash_rate_display\getHeight! --temporary manual margin

  research_rate_display.update = =>
    value =  data.research_rate + data.research * data.research_multiplier
    if value < 0
      research_rate_display\setText "#{format_commas string.format "%.2f", round value, .01}/s"
    else
      research_rate_display\setText "+#{format_commas string.format "%.2f", round value, .01}/s"
    research_rate_display\move -margin, -margin*3 - cash_rate_display\getHeight! --temporary manual margin

  danger_rate_display.update = =>
    value = data.danger_rate + data.danger * data.danger_multiplier
    if value < 0
      danger_rate_display\setText "#{format_commas string.format "%.2f", round value, .01}%/s"
    else
      danger_rate_display\setText "+#{format_commas string.format "%.2f", round value, .01}%/s"
    danger_rate_display\move nil, -margin*3 - cash_rate_display\getHeight! -- temporary manual margin

  tip = pop.text({fontSize: 20})\align "left", "bottom"

  timers.every 1, ->
    for icon in *icons
      if icon.trigger.random
        if random! <= icon.trigger.random
          unless icon.trigger.multiple
            icon.trigger.random = nil
          data.cleared_randoms[icon.id] = true
          icons.add_icon icon

  tooltip_box = pop.box()
  tooltip_text = pop.text(tooltip_box, 20)
  tooltip_box.mousemoved = (x, y, dx, dy) =>
    @move dx, dy

  paused_overlay = pop.box({w: graphics.getWidth!, h: graphics.getHeight!, draw: false})
  pop.box(paused_overlay) -- experiment

  resume = pop.icon(paused_overlay, {w: icon_size, h: icon_size, icon: "icons/play-button.png", tooltip: ""})\align nil, "center"
  resume\move margin, -icon_size - margin
  pop.text(resume, "Resume game.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
  resume.clicked = (x, y, button) =>
    paused_overlay.data.draw = false
    state.paused = false
    return true

  open_save_location = pop.icon(paused_overlay, {w: icon_size, h: icon_size, icon: "icons/open-folder.png", tooltip: ""})\align nil, "center"
  open_save_location\move margin
  pop.text(open_save_location, "Open saved data location.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
  open_save_location.clicked = (x, y, button) =>
    love.system.openURL "file://" .. love.filesystem.getSaveDirectory!
    return true

  exit = pop.icon(paused_overlay, {w: icon_size, h: icon_size, icon: "icons/power-button.png", tooltip: ""})\align nil, "center"
  exit\move margin, icon_size + margin
  pop.text(exit, "Save and exit game.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
  exit.clicked = (x, y, button) =>
    exit_action = "save_data"
    love.event.quit!
    --return true

  debug_button = pop.icon(paused_overlay, {w: icon_size, h: icon_size, icon: "icons/rune-sword.png", tooltip: ""})\align "center", "center"
  debug_button\move icon_size / 2, -icon_size - margin
  pop.text(debug_button, "Debug tools (cheats).", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
  debug_button.clicked = (x, y, button) =>
    data.cash += 50000
    data.research += 10
    data.danger -= data.danger * 0.99
    data.dirty_cheater = true -- lolololol
    paused_overlay.data.draw = false
    state.paused = false
    return true

  reset = pop.icon(paused_overlay, {w: icon_size, h: icon_size, icon: "icons/save.png", tooltip: ""})\align "center", "center"
  reset\move icon_size / 2
  pop.text(reset, "Reset game data.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
  reset.clicked = (x, y, button) =>
    exit_action = "reset_data"
    love.event.quit "restart"
    --return true

  visit_webpage = pop.icon(paused_overlay, {w: icon_size, h: icon_size, icon: "icons/world.png"})\align "center", "center"
  visit_webpage\move icon_size / 2, icon_size + margin
  pop.text(visit_webpage, "Visit website.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
  visit_webpage.clicked = (x, y, button) =>
    love.system.openURL "https://guard13007.itch.io/scp-clicker"
    return true

  icons.add_icon({
    id: 0 -- the pause button being another icon was a bad design I think...
    trigger: {}
    icon: "icons/pause-button.png"
    tooltip: "Pause the game."
    apply: (element) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          paused_overlay.data.draw = true
          state.paused = true
          pop.focused = false
          return true
  })

  load!

  title_screen = pop.box({w: graphics.getWidth!, h: graphics.getHeight!})
  title_screen.clicked = (x, y, button) =>
    state.paused = false
    title_screen\delete!
    return true
  pop.text(title_screen, "SCP Clicker", 60)\align("center", "top")\move nil, "20"
  pop.text(title_screen, "Secure, -Click-, Protect", 26)\align("center", "top")\move nil, 90
  pop.text(title_screen, "Click anywhere to begin.", 26)\align("center", "bottom")\move nil, -20
  if data.check_for_updates
    version_display = pop.text(title_screen, "Current version: "..version.." Latest version: Checking for latest version...", 16)\align("left", "bottom")\move 2
    thread = love.thread.newThread "version-check.lua"
    send = love.thread.getChannel "send"
    receive = love.thread.getChannel "receive"
    thread\start!
    send\push version
  else
    version_display = pop.text(title_screen, "Current version: "..version, 16)\align("left", "bottom")\move 2
  align_grid = pop.box(title_screen, {w: icon_size*4+margin*5, h: icon_size*2+margin*3})\align("center", "center")\move nil, 40
  icon_list = shuffle love.filesystem.getDirectoryItems "icons"
  for x=1,4
    for y=1,2
      name = table.remove icon_list, 1
      pop.icon(align_grid, {w: icon_size, h: icon_size, icon: "icons/#{name}", tooltip: ""})\move (x-1)*icon_size + x*margin, (y-1)*icon_size + y*margin

love.update = (dt) ->
  if version_display and data.check_for_updates
    receive = love.thread.getChannel "receive"
    if receive\getCount! > 0
      version_display\setText(receive\demand!)\move 2

  if state.paused return

  pop.update dt

  data.cash += data.cash_rate * dt
  data.research += data.research_rate * dt
  data.danger += data.danger_rate * dt

  data.cash += math.min math.abs(data.cash) * data.cash_multiplier * dt, 500 * dt
  data.research += data.research * data.research_multiplier * dt
  data.danger += data.danger * data.danger_multiplier * dt

  if data.danger < 0
    data.danger = 0

  if data.danger > 100
    game_over "Danger reached 100%, the world is over."

  if data.cash < 0
    game_over "The Foundation has gone backrupt.\nNow who will protect the world? :("

  for icon in *icons
    unless icon.activated
      if icon.trigger.danger_increasing and icon.trigger.danger_increasing <= data.danger_rate + data.danger * data.danger_multiplier
        icons.add_icon icon
      elseif icon.trigger.all
        -- if less than current, do not trigger
        if icon.trigger.danger_decreasing and icon.trigger.danger_decreasing < data.danger_rate + data.danger * data.danger_multiplier
          continue
        active = true
        for key, value in pairs data
          if icon.trigger.all[key] and value < icon.trigger.all[key]
            active = false
            break
        if active
          icons.add_icon icon
      else
        for key, value in pairs data
          if icon.trigger[key] and value >= icon.trigger[key]
            icons.add_icon icon
            break

  job = 1
  while job <= #timers
    if timers[job]\update dt
      table.remove timers, job
    else
      job += 1

  if data.cash_rate + math.min(math.abs(data.cash) * data.cash_multiplier, 500) < -20 or data.cash < 60
    tip\setText "Be careful, if you go below $0, the Foundation goes backrupt. Game over."
    tip\move margin, -margin*5 - tip\getHeight!*2 -- manual margin
  elseif data.cash_rate + math.min(math.abs(data.cash) * data.cash_multiplier, 500) > 0 or data.cash > 1200
    if tip.data.text == "Be careful, if you go below $0, the Foundation goes backrupt. Game over."
      tip\setText ""

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

love.wheelmoved = (x, y) ->
  pop.wheelmoved x, y

love.keypressed = (key) ->
  if key == "escape"
    exit_action = "save_data"
    love.event.quit!
  elseif key == "d"
    debug = not debug

love.quit = ->
  if exit_action == "reset_data"
    love.filesystem.remove "save.txt"
  elseif exit_action == "save_data"
    --data.icons = {}
    --for icon in *icon_grid.child
    --  table.insert data.icons, icon.id
    love.filesystem.write "save.txt", serialize data

  return
