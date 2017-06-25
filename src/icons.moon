import round, weightedchoice, wordwrap from require "lib.lume"
import graphics from love
import split_newline from require "util"

pop = require "lib.pop"
beholder = require "lib.beholder"
slam = require "lib.slam"

data = require "data"
timers = require "timers"
descriptions = require "descriptions"
state = require "state"

local icons

icons = {
  format_commas: (num) ->
    result = num
    while true
      result, k = string.gsub(result, "^(-?%d+)(%d%d%d)", "%1,%2")
      break if k==0
    return result
  format_cash: (value) ->
    if value < 0
      return "-$#{icons.format_commas string.format "%.2f", round math.abs(value), .01} cash"
    else
      return "+$#{icons.format_commas string.format "%.2f", round value, .01} cash"
  format_research: (value) ->
    if value < 0
      return "#{icons.format_commas string.format "%.2f", round value, .01} research"
    else
      return "+#{icons.format_commas string.format "%.2f", round value, .01} research"
  format_danger: (value) ->
    if value < 0
      return "#{icons.format_commas string.format "%.2f", round value, .01}% danger"
    else
      return "+#{icons.format_commas string.format "%.2f", round value, .01}% danger"
  format_time: (value) ->
    if value > 60*60
      return "#{math.floor value/(60*60)}h#{math.floor (value % (60*60)) / 60}m#{value % 60}s"
    elseif value > 60
      return "#{math.floor value/60}m#{value % 60}s"
    else
      return "#{value}s"
  format_cash_rate: (value) ->
    if value < 0
      return "-$#{icons.format_commas string.format "%.2f", round math.abs(value), .01}/s cash"
    else
      return "+$#{icons.format_commas string.format "%.2f", round value, .01}/s cash"
  format_research_rate: (value) ->
    if value < 0
      return "#{icons.format_commas string.format "%.2f", round value, .01}/s research"
    else
      return "+#{icons.format_commas string.format "%.2f", round value, .01}/s research"
  format_danger_rate: (value) ->
    if value < 0
      return "#{icons.format_commas string.format "%.2f", round value, .01}%/s danger"
    else
      return "+#{icons.format_commas string.format "%.2f", round value, .01}%/s danger"
  format_cash_multiplier: (value) ->
    if value < 0
      return "-x$#{icons.format_commas string.format "%.2f", round math.abs(value), .01} cash"
    else
      return "+x$#{icons.format_commas string.format "%.2f", round value, .01} cash"
  format_class_d_count: (value) ->
    if value < 0
      return "#{icons.format_commas value} Class D personnel"
    else
      return "+#{icons.format_commas value} Class D personnel"

  replace: (data) ->
    s = data.tooltip
    t = {}

    t.cash = icons.format_cash data.cash if data.cash
    t.research = icons.format_research data.research if data.research
    t.danger = icons.format_danger data.danger if data.danger
    t.time = icons.format_time data.time if data.time

    t.cash_rate = icons.format_cash_rate data.cash_rate if data.cash_rate
    t.research_rate = icons.format_research_rate data.research_rate if data.research_rate
    t.danger_rate = icons.format_danger_rate data.danger_rate if data.danger_rate

    t.cash_multiplier = icons.format_cash_multiplier data.cash_multiplier if data.cash_multiplier
    t.class_d_count = icons.format_class_d_count data.class_d_count if data.class_d_count

    (s\gsub('($%b{})', (w) -> t[w\sub(3, -2)] or w))

  wrap: (str, width, font) ->
    return wordwrap str, (text) -> return true if width < font\getWidth text

  scp_info: (element) ->
    state.paused = true
    overlay = pop.box({w: graphics.getWidth! * 9/10, h: graphics.getHeight! * 9/10})\setColor(255, 255, 255, 255)\align "center", "center"
    title = element.data.tooltip
    if n = title\find "\n"
      title = title\sub 1, n
    pop.text(overlay, {hoverable: false}, title, 32)\setColor(0, 0, 0, 255)\align "center", "top"
    display_text = pop.text(overlay, {hoverable: false}, 18)\setColor 0, 0, 0, 255
    fullDescription = split_newline icons.wrap element.data.description\gsub("    ", ""), overlay.data.w - 8, display_text.font
    lines, currentLine = {}, 0
    for i=1,20
      lines[i] = fullDescription[i]
    newText = (table.concat lines, "\n")\gsub "\n.\n", "\n\n"
    if "\n." == newText\sub -2
      newText = newText\sub 1, -2
    display_text\setText newText
    display_text\move 4, 42
    pop.text(overlay, {hoverable: false}, "(click to close)", 16)\setColor(0, 0, 0, 255)\align "center", "bottom"
    overlay.clicked = (x, y, button) =>
      state.paused = false
      overlay\delete!
    overlay.wheelmoved = (x, y) =>
      currentLine -= math.floor y -- just in case it is possible to get a non-integer value
      if currentLine < 0 or #fullDescription < 20
        currentLine = 0
      elseif currentLine > #fullDescription - 20
        currentLine = #fullDescription - 20
      lines = {}
      for i=1,20
        lines[i] = fullDescription[currentLine+i]
      newText = (table.concat lines, "\n")\gsub "\n.\n", "\n\n"
      if ".\n" == newText\sub 1, 2
        newText = newText\sub 2
      if "\n." == newText\sub -2
        newText = newText\sub 1, -2
      display_text\setText newText
      display_text\move 4, 42

  choose_scp: (flags={}) ->
    -- warn if we lack containment capacity
    if data.scp_count == data.site_count * 5
      return icons[37]

    -- then determine whether we return anything at all
    unless flags.debug
      if math.random! > (#icons - #data.cleared_scps) / #icons / 1.2
        return false

    tbl = {}
    for key, icon in ipairs icons
      if icon.trigger.scp
        if icon.trigger.cleared_scp
          if data.cleared_scps[icon.trigger.cleared_scp]
            tbl[key] = icon.trigger.scp
        else
          tbl[key] = icon.trigger.scp
    scp = icons[weightedchoice tbl]

    -- if we're asking for a specific ID, grab it instead
    if flags.id
      scp = icons[flags.id]

    if scp.trigger.multiple
      if data.scp_multiples[scp.id]
        data.scp_multiples[scp.id] += 1
      else
        data.scp_multiples[scp.id] = 1
    else
      scp.trigger.scp = nil
    unless data.cleared_scps[scp.id]
      data.scp_count += 1
      beholder.trigger "NEW_SCP"
    data.cleared_scps[scp.id] = true
    return scp

  basic_scp: (element) ->
    element.clicked = (x, y, button) =>
      if button == pop.constants.left_mouse
        data.cash += element.data.cash if element.data.cash
        data.research += element.data.research if element.data.research
        data.danger += element.data.danger if element.data.danger
        data.cash_rate += element.data.cash_rate if element.data.cash_rate
        data.research_rate += element.data.research_rate if element.data.research_rate
        data.danger_rate += element.data.danger_rate if element.data.danger_rate
  multiple_scp: (element, build_only) ->
    count = 0
    for child in *icons.icon_grid.child
      if child.data.id == element.data.id
        count += 1
    if count > 1
      unless build_only
        data.cash_rate += element.data.cash_rate if element.data.cash_rate
        data.research += element.data.research if element.data.research
      return false
    bg = pop.box(element)\align("left", "bottom")\setColor 255, 255, 255, 255
    fg = pop.text(bg, 20)\setColor 0, 0, 0, 255
    fg.update = =>
      fg\setText data.scp_multiples[element.data.id]
      bg\setSize fg\getSize!
    unless build_only
      data.cash_rate += element.data.cash_rate if element.data.cash_rate
      data.research += element.data.research if element.data.research
    element.clicked = (x, y, button) =>
      if button == pop.constants.right_mouse
        icons.scp_info element
  toggleable_scp: (element, data_key) ->
    bg = pop.box(element)\align("left", "bottom")\setColor 255, 255, 255, 255
    fg = pop.text(bg, 20)\setColor 0, 0, 0, 255
    if data[data_key]
      fg\setText "ACTIVE"
    else
      fg\setText "INACTIVE"
    element.clicked = (x, y, button) =>
      if button == pop.constants.left_mouse
        if data[data_key] or data.cash >= math.abs element.data.cash_rate
          data[data_key] = not data[data_key]
          if data[data_key]
            data.research_rate += element.data.research_rate
            data.cash_rate += element.data.cash_rate
            fg\setText "ACTIVE"
          else
            data.research_rate -= element.data.research_rate
            data.cash_rate -= element.data.cash_rate
            fg\setText "INACTIVE"
          bg\setSize fg\getSize!
      elseif button == pop.constants.right_mouse
        icons.scp_info element
    -- dunno why these are needed...
    bg\setSize fg\getSize!
    fg\align!

  trigger_click: (id, click=pop.constants.left_mouse, element=pop.screen) ->
    if element.data.id and element.data.id == id
      element\clicked 0, 0, click
    else
      for child in *element.child
        icons.trigger_click id, click, child

  { -- 1 ACTION get cash
    trigger: {danger: 0.031}
    icon: "icons/banknote.png"
    tooltip: "Get funds.\n${cash}, ${danger}"
    tip: "You should probably get some cash."
    cash: 100
    danger: 0.2
    apply: (element) ->
      icons.basic_scp element
  }
  { -- 2 ACTION research SCPs
    trigger: {scp_count: 2}
    icon: "icons/soap-experiment.png"
    tooltip: "Research contained SCPs.\n${cash} & ${research} per SCP, ${danger} per SCP (maximum +99% danger)"
    cash: -800
    research: 1
    danger: 2
    apply: (element) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= -1 * element.data.cash * data.scp_count
            data.cash += element.data.cash * data.scp_count
            data.research += element.data.research * data.scp_count
            data.danger += math.min element.data.danger * data.scp_count, 99
            beholder.trigger "SCPS_RESEARCHED"
  }
  { -- 3 RESOURCE savings accounts
    trigger: {cash: 5000}
    icon: "icons/piggy-bank.png"
    tooltip: "Open a savings account.\n${cash}, ${cash_rate}"
    cash: -600
    cash_rate: 1
    apply: (element) ->
      update_cash = ->
        icons[3].cash = -(600 + 50 * data.savings_accounts)
        icons[3].cash_rate = 1 + data.savings_accounts / 2
      update_cash!
      bg = pop.box(element)\align "left", "bottom"
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      fg.update = =>
        fg\setText data.savings_accounts
        bg\setSize fg\getSize!
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.cash_rate += element.data.cash_rate
            data.savings_accounts += 1
        elseif button == pop.constants.right_mouse and data.savings_accounts > 0
          data.cash -= element.data.cash * 0.9
          data.cash_rate -= element.data.cash_rate
          data.savings_accounts -= 1
        update_cash!
  }
  { -- 4 ACTION expending class-d to enact emergency ritual with no other consequence
    trigger: {all: {danger: 10, class_d_count: 10}}
    icon: "icons/moebius-star.png"
    tooltip: "Use Class D personnel to complete emergency containment rituals.\n${cash}, ${danger}, ${class_d_count}"
    cash: -250
    danger: -6
    class_d_count: -10
    apply: (element) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs(element.data.cash) and data.class_d_count > math.abs(element.data.class_d_count) + element.data.class_d_count * icons[12].cash and data.danger > 0.1
            data.cash += element.data.cash - icons[12].cash * element.data.class_d_count -- negative times negative, but needs to be negative, so subtracted
            data.cash_rate += icons[12].cash_rate * element.data.class_d_count -- two negatives being multiplied, so we add it
            data.danger += element.data.danger
            data.danger_rate += icons[12].danger_rate * element.data.class_d_count
            data.class_d_count += element.data.class_d_count -- adding negative to remove it
  }
  { -- 5 RESOURCE hire agent
    trigger: {danger: 0.1}
    icon: "icons/person.png"
    tooltip: "Hire an agent.\n${cash_rate}, ${danger_rate}"
    tip: "If danger reaches 100%, the world ends. Hire agents to bring down the danger level!"
    cash_rate: -1.2
    danger_rate: -0.04
    apply: (element) ->
      bg = pop.box(element)\align "left", "bottom"
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      fg.update = =>
        fg\setText data.agent_count
        bg\setSize fg\getSize!
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs element.data.cash_rate
            data.cash_rate += element.data.cash_rate
            data.danger_rate += element.data.danger_rate
            data.agent_count += 1
        elseif button == pop.constants.right_mouse and data.agent_count > 0
          data.cash_rate -= element.data.cash_rate
          data.danger_rate -= element.data.danger_rate
          data.agent_count -= 1
          icons[9].agent_count = data.agent_count
          beholder.trigger "AGENT_LOST"
  }
  { -- 6 ACTION go on expedition
    trigger: {cash: 6200}
    icon: "icons/treasure-map.png"
    tooltip: "Send an expedition to find SCPs.\n${cash}, ${danger}, ${time}"
    tip: "Expeditions are dangerous. Make sure you have enough agents to handle it."
    cash: -5000
    danger: 10
    time: 20
    sfx: slam.audio.newSource "sfx/expedition-complete.wav", "static"
    apply: (element) ->
      bg = pop.box(element)\align("left", "bottom")\setSize(element.data.w, 8 + 4)
      fg = pop.box(bg)\setColor 255, 255, 255, 255
      fg\setSize data.expedition_progress, 8
      fg\move 2, 2
      fn = ->
        timers.continuous (dt) ->
          goal = element.data.w - 4
          fg\setSize fg\getWidth! + goal/element.data.time * dt, 8
          data.expedition_progress = fg\getWidth!
          fg\move 2, 2
          if fg\getWidth! >= goal
            fg\setSize 0, 0
            data.expedition_running = false
            data.expedition_progress = 0
            icons.add_icon icons.choose_scp!
            icons[6].sfx\play!
            return true
      if data.expedition_running
        fn!
      element.clicked = (x, y, button) =>
        if data.cash >= math.abs(element.data.cash) and not data.expedition_running
          data.expedition_running = true
          data.cash += element.data.cash
          data.danger += element.data.danger
          fn!
  }
  { -- 7 SCP the broken desert
    trigger: {scp: 0.01, multiple: true} -- 1% chance of being chosen
    icon: "icons/cracked-glass.png"
    tooltip: "SCP-132 \"The Broken Desert\"\n${cash_rate} containment cost per instance, ${research} per instance"
    cash_rate: -0.2
    research: 4
    apply: (element, build_only) ->
      icons.multiple_scp element, build_only
  }
  { -- 8 EVENT agent deaths
    trigger: {random: 0.45/60, multiple: true} -- 45% chance per minute
    icon: "icons/morgue-feet.png"
    tooltip: "An agent has died.\n(click to dismiss)"
    tip: "When agents die, things get dangerous..."
    tipOnce: true --NOTE tipOnces are not saved, I don't care
    apply: (element, build_only) ->
      unless build_only
        if data.agent_count > 0
          data.agent_count -= 1
          data.cash_rate -= icons[5].cash_rate*0.9
          data.danger_rate -= icons[5].danger_rate*1.1
          beholder.trigger "AGENT_LOST"
        else
          element\delete!
          return false -- cancel the action!
      element.clicked = (x, y, button) =>
        element\delete!
  }
  { -- 9 TOGGLE automatic agent re-hire
    trigger: {agent_count: 20}
    icon: "icons/hammer-sickle.png"
    tooltip: "Hire replacement agents automatically.\n${cash_rate}"
    cash_rate: -4
    update: false -- inactive by default
    apply: (element) ->
      bg = pop.box(element)\align("left", "bottom")\setColor 0, 0, 0, 255
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      element.data.agent_count = data.agent_count
      element.update = =>
        if data.agent_count < element.data.agent_count
          data.cash_rate += icons[5].cash_rate
          data.danger_rate += icons[5].danger_rate
          data.agent_count += 1
        elseif data.agent_count > element.data.agent_count
          element.data.agent_count = data.agent_count
      if data.agent_rehire_enabled
        fg\setText "ACTIVE"
        element.data.update = true
      else
        fg\setText "INACTIVE"
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          -- if turning off, or have cash to turn on
          if not element.data.update or data.cash >= math.abs(element.data.cash_rate)
            element.data.update = not element.data.update
            if element.data.update
              data.cash_rate += element.data.cash_rate
              element.data.agent_count = data.agent_count
              data.agent_rehire_enabled = true
              fg\setText "ACTIVE"
            else
              data.cash_rate -= element.data.cash_rate
              data.agent_rehire_enabled = false
              fg\setText "INACTIVE"
            bg\setSize fg\getSize!
      -- dunno why these are needed...
      bg\setSize fg\getSize!
      fg\align!
  }
  { -- 10 RESOURCE open banks
    trigger: {savings_accounts: 8}
    icon: "icons/bank.png"
    tooltip: "Open a bank.\n${cash}, ${cash_multiplier} (maximum +$500/s cash)"
    tip: "Banks require money in order to make money. Keep that in mind."
    cash: -4000
    cash_multiplier: 1/100
    apply: (element) ->
      update_cash = ->
        icons[10].cash = -(4000 + 800 * data.bank_count)
      update_cash!
      bg = pop.box(element)\align "left", "bottom"
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      fg.update = =>
        fg\setText data.bank_count
        bg\setSize fg\getSize!
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.cash_multiplier += element.data.cash_multiplier
            data.bank_count += 1
        elseif button == pop.constants.right_mouse and data.bank_count > 0
          data.cash -= element.data.cash * 0.4
          data.cash_multiplier -= element.data.cash_multiplier
          data.bank_count -= 1
        update_cash!
  }
  { -- 11 ACTION emergency ritual
    trigger: {danger_increasing: 2.25}
    icon: "icons/pentagram-rose.png"
    tooltip: "Complete a ritual to reduce danger.\n${cash}, ${danger}, ${danger_rate}"
    cash: -2500
    danger: -20
    danger_rate: 0.25
    apply: (element) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.danger += element.data.danger
            data.danger_rate += element.data.danger_rate
  }
  { -- 12 RESOURCE class-d personnel
    trigger: {agent_count: 8}
    icon: "icons/convict.png"
    tooltip: "Class D personnel, cheaper than agents, more expendable.\n${cash_rate}, ${danger_rate} (${cash} to terminate)\n(at least 1 agent per 10 Class D personnel required)"
    cash: -0.15 -- note: this is used for terminating only
    cash_rate: -0.25
    danger_rate: -0.01
    apply: (element) ->
      terminate = ->
        data.cash += element.data.cash
        data.cash_rate -= element.data.cash_rate
        data.danger_rate -= element.data.danger_rate
        data.class_d_count -= 1
      element.update = =>
        while data.class_d_count / 10 > data.agent_count
          terminate!
      bg = pop.box(element)\align "left", "bottom"
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      bg2 = pop.box(element)\align "right", "top"
      fg2 = pop.text(bg2, 20)\setColor 255, 255, 255, 255
      fg.update = =>
        fg\setText data.class_d_count
        bg\setSize fg\getSize!
        fg2\setText "(#{data.class_d_count}/#{data.agent_count*10})"
        bg2\setSize fg2\getSize!
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs(element.data.cash_rate) and data.agent_count > data.class_d_count / 10
            data.cash_rate += element.data.cash_rate
            data.danger_rate += element.data.danger_rate
            data.class_d_count += 1
        elseif button == pop.constants.right_mouse and data.class_d_count > 0
          if data.cash >= math.abs element.data.cash
            terminate!
  }
  { -- 13 SCP the plague doctor
    trigger: {scp: 0.10}
    icon: "icons/bird-mask.png"
    tooltip: "SCP-049 \"The Plague Doctor\"\n${cash_rate} containment cost, ${research_rate} while contained"
    cash_rate: -2.5
    research_rate: 0.1
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.research_rate += element.data.research_rate
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
  }
  { -- 14 SCP MalO (never be alone)
    trigger: {scp: 0.001, multiple: true}
    icon: "icons/smartphone.png"
    tooltip: "SCP-1471 (MalO ver1.0.0)\n${cash_rate} containment cost per instance, ${research} per instance"
    cash_rate: -0.3
    research: 6
    apply: (element, build_only) ->
      icons.multiple_scp element, build_only
  }
  { -- 15 TOGGLE automatic expeditions
    trigger: {all: {danger_decreasing: -3, scp_count: 5}}
    icon: "icons/helicopter.png"
    tooltip: "Send out expeditions automatically.\n${cash_rate}, ${research_rate}"
    tip: "Be careful about being too aggressive with your expeditions."
    cash_rate: -12
    research_rate: 0.04
    apply: (element) ->
      bg = pop.box(element)\align("left", "bottom")\setColor 0, 0, 0, 255
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      element.update = =>
        unless data.expedition_running
          icons.trigger_click 6
      if data.automatic_expeditions
        element.data.update = true
        fg\setText "ACTIVE"
      else
        element.data.update = false
        fg\setText "INACTIVE"
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          -- if turning off, or have cash to turn on
          if not element.data.update or data.cash >= math.abs element.data.cash_rate
            element.data.update = not element.data.update
            if element.data.update
              data.cash_rate += element.data.cash_rate
              data.research_rate += element.data.research_rate
              data.automatic_expeditions = true
              fg\setText "ACTIVE"
            else
              data.cash_rate -= element.data.cash_rate
              data.research_rate -= element.data.research_rate
              data.automatic_expeditions = false
              fg\setText "INACTIVE"
            bg\setSize fg\getSize!
      -- dunno why these are needed...
      bg\setSize fg\getSize!
      fg\align!
  }
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
  { -- 17 SCP failed werewolf
    trigger: {scp: 0.12}
    icon: "icons/werewolf.png"
    tooltip: "SCP-1540 \"Failed Werewolf\"\n${cash_rate} containment cost, ${research_rate} while contained"
    cash_rate: -3.2
    research_rate: 0.32
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.research_rate += element.data.research_rate
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
  }
  { -- 18 SCP RONALD REGAN CUT UP WHILE TALKING
    trigger: {scp: 0.15}
    icon: "icons/video-camera.png"
    tooltip: "SCP-1981 \"RONALD REGAN CUT UP WHILE TALKING\"\n${cash_rate} research cost, ${research_rate}\n(click to research)"
    cash_rate: -6.2
    research_rate: 0.4
    apply: (element, build_only) ->
      icons.toggleable_scp element, "ronald_regan"
  }
  { -- 19 SCP self-defense sugar
    trigger: {scp: 0.25}
    icon: "icons/amphora.png"
    tooltip: "SCP-989 \"Self-Defense Sugar\""
    apply: (element, build_only) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
  }
  { -- 20 SCP the director's cut
    trigger: {scp: 0.25}
    icon: "icons/salt-shaker.png"
    tooltip: "SCP-981 \"The Director's Cut\""
    apply: (element, build_only) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
  }
  { -- 21 SCP desert in a can
    trigger: {scp: 0.006, multiple: true}
    icon: "icons/spray.png"
    tooltip: "SCP-622 \"Desert in a Can\"\n${cash_rate} containment cost per instance"
    cash_rate: -0.28
    apply: (element, build_only) ->
      icons.multiple_scp element, build_only
  }
  { -- 22 SCP book of endings
    trigger: {scp: 0.20}
    icon: "icons/death-note.png"
    tooltip: "SCP-152 \"Book of Endings\"\n${cash_rate} research cost, ${research_rate}"
    cash_rate: -7.5
    research_rate: 5
    apply: (element, build_only) ->
      icons.toggleable_scp element, "book_of_endings"
  }
  { -- 23 SCP diet ghost
    trigger: {scp: 0.002, multiple: true}
    icon: "icons/soda-can.png"
    tooltip: "SCP-2107 \"Diet Ghost\"\n${cash_rate} containment cost per instance"
    cash_rate: -0.26
    apply: (element, build_only) ->
      icons.multiple_scp element, build_only
  }
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
  { -- 25 SCP the clockworks
    trigger: {scp: 0.15}
    icon: "icons/gear-hammer.png"
    tooltip: "SCP-914 \"The Clockworks\"\n${cash_rate} containment cost, ${research_rate} while contained, ${danger_rate}"
    cash_rate: -2
    research_rate: 0.6
    danger_rate: 0.02
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.research_rate += element.data.research_rate
        data.danger_rate += element.data.danger_rate
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
  }
  { -- 26 EVENT clockwork-caused breach
    trigger: {random: 0.01/60, cleared_scp: 25, multiple: true} -- 1% per minute
    icon: "icons/clockwork.png"
    tooltip: "Containment breach caused by SCP-914!\n${cash_rate} until contained, ${danger_rate} until contained\n${cash} to attempt containment"
    tip: "Breaches can escalate danger and cause a loss pretty quickly. Be wary, and stop them quickly."
    tipOnce: true
    cash_rate: -40
    danger_rate: 1.6
    danger: 30
    cash: -10000
    apply: (element, build_only) ->
      unless data.cleared_scps[26]   -- temporary check and self-destruction because of issue #73
        return false
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.danger_rate += element.data.danger_rate
        data.danger += element.data.danger
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.cash_rate -= element.data.cash_rate
            data.danger_rate -= element.data.danger_rate
            element\delete!
  }
  { -- 27 SCP best of the 5th dimension
    trigger: {random: 0.01/60}   -- 1% per minute
    icon: "icons/compact-disc.png"
    tooltip: "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n0/3125 disks researched, ${cash} research cost, ${research}, ${danger}\n(click to research)"
    cash: -15
    research: 10
    danger: 2.5
    apply: (element, build_only) ->
      if data.scp092_researched_count == 3125
        element.data.tooltip = "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n3125/3125 disks researched"
      else
        element.data.tooltip = "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n#{data.scp092_researched_count}/3125 disks researched, ${cash} research cost, ${research}\n(click to research)"
      update_cash = ->
        --icons[27].cash = -(1.05 * (data.scp092_researched_count + 625) ^ 0.65 + 1.05 ^ (data.scp092_researched_count / 25) - 55)
        icons[27].cash = -(1.05 * (data.scp092_researched_count + 625) ^ 0.75 + 1.1 ^ (data.scp092_researched_count / 25) - 55)
      update_cash!
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.scp092_researched_count < 3124 and data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.research += element.data.research
            data.danger += element.data.danger
            data.scp092_researched_count += 1
            update_cash!
            if data.scp092_researched_count == 3125
              element.data.tooltip = "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n3125/3125 disks researched"
            else
              element.data.tooltip = "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n#{data.scp092_researched_count}/3125 disks researched, ${cash} research cost, ${research}\n(click to research)"
        elseif button == pop.constants.right_mouse
          icons.scp_info element
  }
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
  { -- 29 SCP many fingers, many toes
    trigger: {scp: 0.38}
    icon: "icons/fractal-hand.png"
    tooltip: "SCP-584 \"Many Fingers, Many Toes\"\n${cash_rate} containment cost, ${research_rate} while contained"
    cash_rate: -4.5
    research_rate: 1.25
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.research_rate += element.data.research_rate
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
  }
  { -- 30 SCP pink flamingos
    trigger: {scp: 0.4}
    icon: "icons/flamingo.png"
    tooltip: "SCP-1507 \"Pink Flamingos\"\n${cash_rate} containment cost, ${research}"
    cash_rate: -3.2
    research: 4.2
    apply: (element, build_only) ->
      if build_only and data.cleared_randoms[31]
        element.data.cash_rate -= icons[31].cash_rate
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.research += element.data.research
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
  }
  { -- 31 EVENT pink flamingo breach
    trigger: {random: 0.04/60, cleared_scp: 30} -- 4% per minute
    icon: "icons/files.png"
    tooltip: "Incident 1507-A\n${cash_rate} increase in containment cost, ${research} research gained\n(click to read, right-click to dismiss)"
    cash_rate: 5
    research: 1
    apply: (element, build_only) ->
      unless data.cleared_scps[30]   -- temporary check and self-destruction because of issue #73
        return false
      unless build_only
        icons[30].cash_rate -= element.data.cash_rate
        icons[30].description = descriptions[30][2]
        data.scp_descriptions[30] = 2
        data.cash_rate -= element.data.cash_rate
        data.research += element.data.research
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          icons.scp_info element
        elseif button == pop.constants.right_mouse
          element\delete!
  }
  { -- 32 TOGGLE automatic research (super dangerous!)
    trigger: {all: {danger_decreasing: -11, scp_count: 10}}
    icon: "icons/fizzing-flask.png"
    tooltip: "Research all contained SCPs automatically.\n${cash_rate} per SCP, ${research_rate} per SCP"
    tip: "Be careful about being too aggressive with research..."
    cash_rate: -1.2
    research_rate: 0.8
    apply: (element) ->
      bg = pop.box(element)\align("left", "bottom")\setColor 0, 0, 0, 255
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      local beholderID
      newSCP = ->
        data.cash_rate += element.data.cash_rate
        data.research_rate += element.data.research_rate
      element.update = =>
        if data.danger <= 0.01 -- won't activate unless you have 1% or less danger
          icons.trigger_click 2
      if data.automatic_research
        element.data.update = true
        fg\setText "ACTIVE"
        beholderID = beholder.observe "NEW_SCP", newSCP
      else
        element.data.update = false
        fg\setText "INACTIVE"
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          -- if turning off, or have cash to turn on
          if not element.data.update or data.cash >= math.abs element.data.cash_rate
            element.data.update = not element.data.update
            if element.data.update
              beholderID = beholder.observe "NEW_SCP", newSCP
              data.cash_rate += element.data.cash_rate * data.scp_count
              data.research_rate += element.data.research_rate * data.scp_count
              data.automatic_research = true
              fg\setText "ACTIVE"
            else
              beholder.stopObserving(beholderID)
              data.cash_rate -= element.data.cash_rate * data.scp_count
              data.research_rate -= element.data.research_rate * data.scp_count
              data.automatic_research = false
              fg\setText "INACTIVE"
            bg\setSize fg\getSize!
      -- dunno why these are needed...
      bg\setSize fg\getSize!
      fg\align!
  }
  { -- 33 TOGGLE automatically recruit class D's
    trigger: {class_d_count: 50}
    icon: "icons/mug-shot.png"
    tooltip: "Recruit Class D personnel automatically.\n${cash_rate}"
    cash_rate: -2.25
    apply: (element) ->
      bg = pop.box(element)\align("left", "bottom")\setColor 0, 0, 0, 255
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      if data.automatic_class_d
        fg\setText "ACTIVE"
      else
        fg\setText "INACTIVE"
      clock = 0
      element.update = (dt) =>
        if data.automatic_class_d
          clock += dt
          if clock >= 0.5
            clock -= 0.5
            icons.trigger_click 12
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.automatic_class_d or data.cash >= math.abs element.data.cash_rate
            data.automatic_class_d = not data.automatic_class_d
            if data.automatic_class_d
              data.cash_rate += element.data.cash_rate
              fg\setText "ACTIVE"
            else
              data.cash_rate -= element.data.cash_rate
              fg\setText "INACTIVE"
            bg\setSize fg\getSize!
      -- dunno why these are needed...
      bg\setSize fg\getSize!
      fg\align!
  }
  { -- 34 EVENT desert in a can MAJOR breach
    trigger: {scps_researched: {scp: 21, random: 0.02}} --a 2% chance every time SCPs are researched
    icon: "icons/heat-haze.png"
    tooltip: "Test Log 622-4, Note from O5-█\n${cash_rate} until contained, ${danger_rate} until contained"
    cash_rate: -160
    danger_rate: 7.2
    danger: 31
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.danger_rate += element.data.danger_rate
        data.danger += element.data.danger
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
  }
  { -- 35 TOGGLE class D termination policy
    trigger: {class_d_count: 200}
    icon: "icons/gibbet.png"
    tooltip: "Class D personnel monthly termination policy.\n${cash_rate}, ${danger_rate}\n(Class D personnel count will fluctuate as they are terminated and replaced.)"
    cash_rate: -35
    danger_rate: -20
    apply: (element) ->
      bg = pop.box(element)\align("left", "bottom")\setColor 0, 0, 0, 255
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      if data.class_d_termination_policy
        fg\setText "ACTIVE"
      else
        fg\setText "INACTIVE"
      clock, interval = 0, 0
      element.update = (dt) =>
        if data.class_d_termination_policy
          clock += dt
          if clock >= interval + 1/10
            interval += 1/10
            count = data.class_d_count / 200 * math.sin(2*math.pi / 10 * clock) -- period of 10 seconds
            if count < 0
              for i=1, math.abs count
                icons.trigger_click 12, pop.constants.right_mouse
            else
              for i=1, count
                icons.trigger_click 12
            if clock >= 10
              clock -= 10
              interval -= 10
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.class_d_termination_policy or data.cash >= math.abs element.data.cash_rate
            data.class_d_termination_policy = not data.class_d_termination_policy
            if data.class_d_termination_policy
              data.cash_rate += element.data.cash_rate
              data.danger_rate += element.data.danger_rate
              fg\setText "ACTIVE"
            else
              data.cash_rate -= element.data.cash_rate
              data.danger_rate -= element.data.danger_rate
              fg\setText "INACTIVE"
            bg\setSize fg\getSize!
      -- dunno why these are needed...
      bg\setSize fg\getSize!
      fg\align!
  }
  { -- 36 RESOURCE containment sites
    trigger: {scp_count: 3}
    icon: "icons/military-fort.png"
    tooltip: "Build a new containment site.\n${cash}, ${cash_rate}\n(1 containment site is needed for every 5 SCPs.)"
    cash: -2500
    cash_rate: -5
    apply: (element) ->
      update_cash = ->
        -- this one differs slightly, because we start with 1
        icons[36].cash = -(2000 + 500 * data.site_count)
        icons[36].cash_rate = -(5 * data.site_count)
      update_cash!
      bg = pop.box(element)\align "left", "bottom"
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      bg2 = pop.box(element)\align "right", "top"
      fg2 = pop.text(bg2, 20)\setColor 255, 255, 255, 255
      fg.update = =>
        fg\setText data.site_count
        bg\setSize fg\getSize!
        fg2\setText "(#{data.scp_count}/#{data.site_count*5})"
        bg2\setSize fg2\getSize!
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.cash_rate += element.data.cash_rate
            data.site_count += 1
        elseif button == pop.constants.right_mouse
          if data.scp_count <= (data.site_count - 1) * 5
            data.cash -= element.data.cash / 2
            data.cash_rate -= element.data.cash_rate
            data.site_count -= 1
        update_cash!
  }
  { -- 37 EVENT warning about lack of containment sites
    trigger: {multiple: true} -- no trigger on this one, choose_scp activates it
    icon: "icons/hazard-sign.png"
    tooltip: "There is no more room for SCPs! Build more containment sites."
    apply: (element) ->
      element.clicked = =>
        element\delete!
  }
  { -- 38 RESOURCE (gold?) mines
    trigger: {cash: 20000, cash_rate: 100}
    icon: "icons/gold-mine.png"
    tooltip: "Open a mine.\n${cash}, ${cash_rate}"
    cash: -6000
    cash_rate: 20
    apply: (element) ->
      update_cash = ->
        icons[38].cash = -(6000 + 200 * data.mine_count)
        icons[38].cash_rate = 20 + 2 * data.mine_count
      update_cash!
      bg = pop.box(element)\align "left", "bottom"
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      fg.update = =>
        fg\setText data.mine_count
        bg\setSize fg\getSize!
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.cash_rate += element.data.cash_rate
            data.mine_count += 1
        elseif button == pop.constants.right_mouse and data.mine_count > 0
          data.cash -= element.data.cash * 0.2
          data.cash_rate -= element.data.cash_rate * 1.05
          data.mine_count -= 1
        update_cash!
  }
  { -- 39 SCP broken spybot
    trigger: {scp: 0.3}
    icon: "icons/metal-disc.png"
    tooltip: "SCP-1599 \"Broken Spybot\"\n${cash_rate} research cost, ${research_rate}"
    cash_rate: -8.4
    research_rate: 5.2
    apply: (element, build_only) ->
      icons.toggleable_scp element, "broken_spybot"
  }
  { -- 40 SCP $҉ 585.98
    trigger: {scp: 0.24}
    icon: "icons/price-tag.png"
    tooltip: "SCP-2395 \"$҉ 585.98\"\n${cash_rate} containment cost"
    cash_rate: -3.15
    apply: (element, build_only) ->
      icons.basic_scp element
  }
  { -- 41 SCP comedy mask
    trigger: {scp: 0.03}
    icon: "icons/duality-mask.png"
    tooltip: "SCP-035 \"Possessive Mask\"\n${cash_rate} containment cost"
    cash_rate: -15
    apply: (element, build_only) ->
      icons.basic_scp element
  }
  { -- 42 SCP to end all wars
    trigger: {scp: 0.01}
    icon: "icons/gas-mask.png"
    tooltip: "SCP-186 \"To End All Wars\"\n${cash_rate} containment cost"
    cash_rate: -32
    apply: (element, build_only) ->
      icons.basic_scp element
  }
  { -- 43 SCP black shuck
    trigger: {scp: 0.42}
    icon: "icons/wolf-head.png"
    tooltip: "SCP-023 \"Black Shuck\"\n${cash_rate} containment cost"
    cash_rate: -8.5
    apply: (element, build_only) ->
      icons.basic_scp element
  }

  --{ -- ?? TOGGLE play the stock market
  --  trigger: {cash: 1000000, cash_rate: 1500}
  --  icon: "icons/chart.png"
  --  -- a better source of income is needed
  --}
}

for i=1, #icons
  icons[i].id = i

-- when descriptions have been set to an alternate, load() function handles this
for id, description in pairs descriptions
  icons[id].description = description[1]

return icons
