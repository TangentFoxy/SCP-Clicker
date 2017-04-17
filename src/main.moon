v = require "lib.semver"
version = v require "version"

math.randomseed(os.time())

import graphics, mouse from love
import round, random, serialize, deserialize, shuffle from require "lib.lume"

pop = require "lib.pop"
icons = require "icons"
data = require "data"
settings = require "settings"
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
  element = pop.icon(icon_grid, icon)\move(x * (icon_size + margin) + margin, y * (icon_size + margin) + margin)
  if false != icon.apply(element, build_only)
    icon.activated = true -- make sure icons are only added once when triggered
    element.wheelmoved = (x, y) =>
      icon_grid\wheelmoved x, y
    for child in *element.child
      child.data.hoverable = false
    --_, y = element\getPosition!
    --if y > icon_grid.data.h - margin*2
    --  element\setPosition -512, -512 -- hide it, it doesn't fit!
    icon_grid\wheelmoved 0, 0
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
    return true -- an icon was set
  return false -- an icon was not set

icons.fix_order = ->
  icon_grid\wheelmoved 0, 0

  if false
    x, y = margin, margin
    data.icons = {}
    for icon in *icon_grid.child
      unless icon.data.id == 0 -- don't save UI elements
        table.insert data.icons, icon.data.id
      icon\setPosition x, y
      x += margin + icon_size
      if x > icon_grid.data.w - margin - icon_size
        x = margin
        y += margin + icon_size
        if y > icon_grid.data.h - margin -- hide it, it doesn't fit!
          y += 512

load = ->
  if loaded_text = love.filesystem.read "settings.txt"
    loaded_settings = deserialize loaded_text
    for key, value in pairs loaded_settings
      settings[key] = value

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
    if loaded_data.version == 2
      settings.check_for_updates = loaded_data.check_for_updates
      loaded_data.version = 3
      loaded_data.check_for_updates = nil

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
  icon_grid.data.currentLine = 0
  icon_grid.wheelmoved = (x, y) =>
    lineWidth = math.floor icon_grid.data.w / (icon_size + margin)
    lines = 1 + math.floor #icon_grid.child / ( lineWidth )
    @data.currentLine -= math.floor y
    if @data.currentLine < 0 or lines < 4
      @data.currentLine = 0
    elseif @data.currentLine > lines - 3
      @data.currentLine = lines - 3
    x, y = margin, margin
    for icon in *@child
      icon\setPosition -512, -512 -- safely off-screen
    for i = 1 + @data.currentLine * lineWidth, (@data.currentLine + 3) * lineWidth
      if icon = @child[i]
        if y > icon_grid.data.h - margin
          icon\setPosition -512, -512 -- safely off-screen
        else
          icon\setPosition x, y
        x += margin + icon_size
        if x > icon_grid.data.w - margin - icon_size
          x = margin
          y += margin + icon_size

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
    if data.cash >= 100000000000000000000
      cash_display\setText "Cash: $#{format_commas string.format "%.2f", round data.cash/1000000000000000000, .01}Q"
    elseif data.cash >= 100000000000000000
      cash_display\setText "Cash: $#{format_commas string.format "%.2f", round data.cash/1000000000000000, .01}q"
    elseif data.cash >= 100000000000000
      cash_display\setText "Cash: $#{format_commas string.format "%.2f", round data.cash/1000000000000, .01}t"
    elseif data.cash >= 100000000000
      cash_display\setText "Cash: $#{format_commas string.format "%.2f", round data.cash/1000000000, .01}b"
    elseif data.cash >= 100000000
      cash_display\setText "Cash: $#{format_commas string.format "%.2f", round data.cash/1000000, .01}m"
    elseif data.cash >= 100000
      cash_display\setText "Cash: $#{format_commas string.format "%.2f", round data.cash/1000, .01}k"
    else
      cash_display\setText "Cash: $#{format_commas string.format "%.2f", round data.cash, .01}"
    cash_display\move margin, -margin --temporary manual margin

  research_display.update = =>
    if data.research >= 100000000000000000000
      research_display\setText "Research: #{format_commas string.format "%.2f", round data.research/1000000000000000000, .01}Q"
    elseif data.research >= 100000000000000000
      research_display\setText "Research: #{format_commas string.format "%.2f", round data.research/1000000000000000, .01}q"
    elseif data.research >= 100000000000000
      research_display\setText "Research: #{format_commas string.format "%.2f", round data.research/1000000000000, .01}t"
    elseif data.research >= 100000000000
      research_display\setText "Research: #{format_commas string.format "%.2f", round data.research/1000000000, .01}b"
    elseif data.research >= 100000000
      research_display\setText "Research: #{format_commas string.format "%.2f", round data.research/1000000, .01}m"
    elseif data.research >= 100000
      research_display\setText "Research: #{format_commas string.format "%.2f", round data.research/1000, .01}k"
    else
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
          if icons.add_icon icon
            unless icon.trigger.multiple
              icon.trigger.random = nil
            data.cleared_randoms[icon.id] = true
          break

  tooltip_box = pop.box()
  tooltip_text = pop.text(tooltip_box, 20)
  tooltip_box.mousemoved = (x, y, dx, dy) =>
    @move dx, dy

  paused_overlay = pop.box({w: graphics.getWidth!, h: graphics.getHeight!, draw: false})

  resume = pop.icon(paused_overlay, {w: icon_size, h: icon_size, icon: "icons/play-button.png", tooltip: ""})\align nil, "center"
  resume\move margin, -icon_size - margin
  pop.text(resume, "Resume game.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
  resume.clicked = (x, y, button) =>
    paused_overlay.data.draw = false
    state.paused = false
    return true

  options_button = pop.icon(paused_overlay, {w: icon_size, h: icon_size, icon: "icons/cog.png", tooltip: ""})\align "center", "center"
  options_button\move icon_size / 2, -icon_size - margin
  pop.text(options_button, "Options / Data", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
  options_button.clicked = (x, y, button) =>
    options_overlay = pop.box({w: graphics.getWidth!, h: graphics.getHeight!})

    back_button = pop.icon(options_overlay, {w: icon_size, h: icon_size, icon: "icons/anticlockwise-rotation.png", tooltip: ""})\align nil, "center"
    back_button\move margin, -icon_size - margin
    pop.text(back_button, "Back to pause menu.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
    back_button.clicked = (x, y, button) =>
      options_overlay\delete!
      return true

    open_save_location = pop.icon(options_overlay, {w: icon_size, h: icon_size, icon: "icons/open-folder.png", tooltip: ""})\align nil, "center"
    open_save_location\move margin
    pop.text(open_save_location, "Open saved data location.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
    open_save_location.clicked = (x, y, button) =>
      love.system.openURL "file://" .. love.filesystem.getSaveDirectory!
      return true

    debug_button = pop.icon(options_overlay, {w: icon_size, h: icon_size, icon: "icons/rune-sword.png", tooltip: ""})\align "center", "center"
    debug_button\move icon_size / 2, -icon_size - margin
    pop.text(debug_button, "Debug tools (cheats).", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
    debug_button.clicked = (x, y, button) =>
      data.cash += 50000
      data.research += 10
      data.danger -= data.danger * 0.99
      data.dirty_cheater = true -- lolololol
      paused_overlay.data.draw = false
      state.paused = false
      options_overlay\delete!
      return true

    reset = pop.icon(options_overlay, {w: icon_size, h: icon_size, icon: "icons/save.png", tooltip: ""})\align "center", "center"
    reset\move icon_size / 2
    pop.text(reset, "Reset game data.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
    reset.clicked = (x, y, button) =>
      exit_action = "reset_data"
      love.event.quit "restart"
      --return true

    toggle_version_check = pop.icon(options_overlay, {w: icon_size, h: icon_size, icon: "icons/aerial-signal.png", tooltip: ""})\align nil, "center"
    toggle_version_check\move margin, icon_size + margin
    local version_check_text
    if settings.check_for_updates
      version_check_text = pop.text(toggle_version_check, "Disable version checking.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
    else
      version_check_text = pop.text(toggle_version_check, "Enable version checking.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
    toggle_version_check.clicked = (x, y, button) =>
      settings.check_for_updates = not settings.check_for_updates
      if settings.check_for_updates
        version_check_text\setText("Disable version checking.")\move icon_size + margin
      else
        version_check_text\setText("Enable version checking.")\move icon_size + margin
      return true

  exit = pop.icon(paused_overlay, {w: icon_size, h: icon_size, icon: "icons/power-button.png", tooltip: ""})\align nil, "center"
  exit\move margin--, icon_size + margin
  pop.text(exit, "Save and exit game.", 24)\setColor(255, 255, 255, 255)\align(nil, "center")\move icon_size + margin
  exit.clicked = (x, y, button) =>
    exit_action = "save_data"
    love.event.quit!
    --return true

  visit_webpage = pop.icon(paused_overlay, {w: icon_size, h: icon_size, icon: "icons/world.png"})\align "center", "center"
  visit_webpage\move icon_size / 2--, icon_size + margin
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
  if settings.check_for_updates
    version_display = pop.text(title_screen, "Current version: #{version} Latest version: Checking for latest version...", 16)\align("left", "bottom")\move 2
    thread = love.thread.newThread "version-check.lua"
    send = love.thread.getChannel "send"
    receive = love.thread.getChannel "receive"
    thread\start!
    send\push version
  else
    version_display = pop.text(title_screen, "Current version: #{version}", 16)\align("left", "bottom")\move 2
  align_grid = pop.box(title_screen, {w: icon_size*4+margin*5, h: icon_size*2+margin*3})\align("center", "center")\move nil, 40
  icon_list = shuffle love.filesystem.getDirectoryItems "icons"
  for x=1,4
    for y=1,2
      name = table.remove icon_list, 1
      pop.icon(align_grid, {w: icon_size, h: icon_size, icon: "icons/#{name}", tooltip: ""})\move (x-1)*icon_size + x*margin, (y-1)*icon_size + y*margin

love.update = (dt) ->
  if settings.check_for_updates
    receive = love.thread.getChannel "receive"
    if receive\getCount! > 0
      latest_version = receive\demand!
      if version_display and version_display.parent
        local display_string
        if latest_version != "error"
          latest_version = v latest_version
          latest_version.build = nil
          if version == latest_version
            display_string = "Current version: #{version} Latest version: #{latest_version} You have the latest version. :D"
          elseif version > latest_version
            display_string = "Current version: #{version} Latest version: #{latest_version} You have an unreleased version. :O"
          else
            display_string = "Current version: #{version} Latest version: #{latest_version} There is a newer version available!"
        else
          display_string = "Current version: #{version} Latest version: Connection error while getting latest version. Trying again..."
        version_display\setText(display_string)\move 2
      else
        if latest_version != "error"
          latest_version = v latest_version
          latest_version.build = nil
          if version < latest_version
            icons.add_icon({
              id: 0 -- any UI element is "ID" zero
              trigger: {}
              icon: "icons/world.png"
              tooltip: "There is a new version of SCP Clicker available: #{latest_version}\nClick to save, quit, and go to Itch.io.\nRight-click to dismiss."
              apply: (element) ->
                element.clicked = (x, y, button) =>
                  if button == pop.constants.left_mouse
                    love.system.openURL "https://guard13007.itch.io/scp-clicker"
                    exit_action = "save_data"
                    love.event.quit!
                  elseif button == pop.constants.right_mouse
                    @delete!
            })

  if state.paused
    -- find and delete click elements!
    for i=#pop.screen.child, 1, -1
      if pop.screen.child[i].data.type == "click"
        pop.screen.child[i]\delete!

    return

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

  if data.cash < -100
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
    tip\setText "Be careful, if you go below -$100, the Foundation goes backrupt. Game over."
    tip\move margin, -margin*5 - tip\getHeight!*2 -- manual margin
  elseif data.cash_rate + math.min(math.abs(data.cash) * data.cash_multiplier, 500) > 0 or data.cash > 1200
    if tip.data.text == "Be careful, if you go below -$100, the Foundation goes backrupt. Game over."
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
  pop.mousereleased x, y, button --NOTE click handled is not being returned!!
  pop.click(24)\move x + random(-8, 4), y + random(-20, -14)

love.wheelmoved = (x, y) ->
  pop.wheelmoved x, y

love.keypressed = (key) ->
  if key == "escape"
    exit_action = "save_data"
    love.event.quit!
  elseif key == "d"
    debug = not debug
  elseif key == "a" and debug
    icons.add_icon icons[8]

love.quit = ->
  if exit_action == "reset_data"
    love.filesystem.remove "save.txt"
  elseif exit_action == "save_data"
    --data.icons = {}
    --for icon in *icon_grid.child
    --  table.insert data.icons, icon.id
    love.filesystem.write "save.txt", serialize data

  love.filesystem.write "settings.txt", serialize settings

  return
