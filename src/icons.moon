import round, weightedchoice, wordwrap from require "lib.lume"
import graphics from love
import split_newline from require "util"

pop = require "lib.pop"
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
      return true
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

  choose_scp: ->
    tbl = {}
    for key, icon in ipairs icons
      if icon.trigger.scp
        tbl[key] = icon.trigger.scp
    scp = icons[weightedchoice tbl]
    unless scp.trigger.multiple
      scp.trigger.scp = nil
    unless data.cleared_scps[scp.id]
      data.scp_count += 1
    data.cleared_scps[scp.id] = true
    return scp

  basic: (element) ->
    element.clicked = (x, y, button) =>
      if button == pop.constants.left_mouse
        data.cash += element.data.cash if element.data.cash
        data.research += element.data.research if element.data.research
        data.danger += element.data.danger if element.data.danger
      return true

  toggleable: (element, data_key) ->
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
      return true
    -- dunno why these are needed...
    bg\setSize fg\getSize!
    fg\align!

  { -- 1 get cash
    trigger: {danger: 0.0215}
    icon: "icons/banknote.png"
    tooltip: "Get funds.\n${cash}, ${danger}"
    tip: "You should probably get some cash."
    cash: 100
    danger: 0.2
    apply: (element) ->
      icons.basic element
  }
  { -- 2 research SCPs
    trigger: {scp_count: 2}
    icon: "icons/soap-experiment.png"
    tooltip: "Research contained SCPs.\n${research} per SCP, ${danger} per SCP (maximum +99% danger)"
    research: 1
    danger: 2
    apply: (element) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          data.research += element.data.research * data.scp_count
          data.danger += math.min element.data.danger * data.scp_count, 99
        return true
  }
  { -- 3 savings accounts
    trigger: {cash: 800}
    icon: "icons/piggy-bank.png"
    tooltip: "Open a savings account.\n${cash}, ${cash_rate}"
    cash: -1000
    cash_rate: 1
    apply: (element) ->
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
        elseif button == pop.constants.right_mouse
          data.cash -= element.data.cash * 0.9
          data.cash_rate -= element.data.cash_rate
          data.savings_accounts -= 1
        return true
  }
  { -- 4 expending class-d to enact emergency ritual with no other consequence
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
        return true
  }
  { -- 5 hire agent
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
        elseif button == pop.constants.right_mouse
          data.cash_rate -= element.data.cash_rate
          data.danger_rate -= element.data.danger_rate
          data.agent_count -= 1
          icons[9].agent_count = data.agent_count
        return true
  }
  { -- 6 go on expedition
    trigger: {cash: 6000}
    icon: "icons/treasure-map.png"
    tooltip: "Send an expedition to find SCPs.\n${cash}, ${danger}, ${time}"
    tip: "Expeditions are dangerous. Make sure you have enough agents to handle it."
    cash: -5000
    danger: 10
    time: 20
    apply: (element) ->
      bg = pop.box(element)\align("left", "bottom")\setSize(element.data.w, 8 + 4)
      fg = pop.box(bg)\setColor 255, 255, 255, 255
      fg\setSize data.expedition_progress, 8
      fg\move 2, 2
      fn = ->
        timers.constant (dt) ->
          goal = element.data.w - 4
          fg\setSize fg\getWidth! + goal/element.data.time * dt, 8
          data.expedition_progress = fg\getWidth!
          fg\move 2, 2
          if fg\getWidth! >= goal
            fg\setSize 0, 0
            data.expedition_running = false
            data.expedition_progress = 0
            icons.add_icon icons.choose_scp!
            return true
      if data.expedition_running
        fn!
      element.clicked = (x, y, button) =>
        if data.cash >= math.abs(element.data.cash) and not data.expedition_running
          data.expedition_running = true
          data.cash += element.data.cash
          data.danger += element.data.danger
          fn!
        return true
  }
  { -- 7 SCP the broken desert
    trigger: {scp: 0.01, multiple: true} -- 1% chance of being chosen
    icon: "icons/cracked-glass.png"
    tooltip: "An instance of SCP-132 \"The Broken Desert\"\n${cash_rate} containment cost, ${research}\n(click to hide)"
    cash_rate: -0.2
    research: 4
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.research += element.data.research
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          element\delete!
        elseif button == pop.constants.right_mouse
          icons.scp_info element
        return true
  }
  { -- 8 agent deaths
    trigger: {random: 0.6/60, multiple: true} -- 60% chance per minute
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
        else
          element\delete!
          return false -- cancel the action!
      element.clicked = (x, y, button) =>
        element\delete!
        return true
  }
  { -- 9 automatic agent re-hire
    trigger: {agent_count: 30}
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
        return true
      -- dunno why these are needed...
      bg\setSize fg\getSize!
      fg\align!
  }
  { -- 10 open banks
    trigger: {savings_accounts: 20}
    icon: "icons/bank.png"
    tooltip: "Open a bank.\n${cash}, ${cash_multiplier} (maximum +$500/s cash)"
    tip: "Banks require money in order to make money. Keep that in mind."
    cash: -6000
    cash_multiplier: 1/100
    apply: (element) ->
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
        elseif button == pop.constants.right_mouse
          data.cash -= element.data.cash * 0.4
          data.cash_multiplier -= element.data.cash_multiplier
          data.bank_count -= 1
        return true
  }
  { -- 11 emergency ritual
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
        return true
  }
  { -- 12 class-d personnel
    trigger: {agent_count: 40}
    icon: "icons/convict.png"
    tooltip: "Class D personnel, cheaper than agents, more expendable.\n${cash_rate}, ${danger_rate} (${cash} to terminate)"
    cash: -0.15 -- note: this is used for terminating only
    cash_rate: -0.25
    danger_rate: -0.01
    apply: (element) ->
      bg = pop.box(element)\align "left", "bottom"
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      fg.update = =>
        fg\setText data.class_d_count
        bg\setSize fg\getSize!
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs element.data.cash_rate
            data.cash_rate += element.data.cash_rate
            data.danger_rate += element.data.danger_rate
            data.class_d_count += 1
        elseif button == pop.constants.right_mouse
          if data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.cash_rate -= element.data.cash_rate
            data.danger_rate -= element.data.danger_rate
            data.class_d_count -= 1
        return true
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
        return true
  }
  { -- 14 SCP MalO (never be alone)
    trigger: {scp: 0.001, multiple: true}
    icon: "icons/smartphone.png"
    tooltip: "An instance of SCP-1471 (MalO ver1.0.0)\n${cash_rate} containment cost, ${research}\n(click to hide)"
    cash_rate: -0.3
    research: 6
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.research += element.data.research
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          element\delete!
        elseif button == pop.constants.right_mouse
          icons.scp_info element
        return true
  }
  { -- 15 automatic expeditions
    trigger: {all: {danger_decreasing: -3, scp_count: 3}}
    icon: "icons/helicopter.png"
    tooltip: "Send out expeditions automatically.\n${cash_rate}, ${research_rate}"
    tip: "Be careful about being too aggressive with your expeditions."
    cash_rate: -12
    research_rate: 0.04
    apply: (element) ->
      bg = pop.box(element)\align("left", "bottom")\setColor 0, 0, 0, 255
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      local recurse
      recurse = (element=pop.screen) ->
        if element.data.id and element.data.id == 6
          if data.cash >= math.abs element.data.cash * 1.25 -- won't activate unless you have $6,250 cash
            element\clicked 0, 0, pop.constants.left_mouse
        else
          for child in *element.child
            recurse child
      element.update = =>
        unless data.expedition_running
          recurse!
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
        return true
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
        return true
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
        return true
  }
  { -- 18 SCP RONALD REGAN CUT UP WHILE TALKING
    trigger: {scp: 0.15}
    icon: "icons/video-camera.png"
    tooltip: "SCP-1981 \"RONALD REGAN CUT UP WHILE TALKING\"\n${cash_rate} research cost, ${research_rate}\n(click to research)"
    cash_rate: -6.2
    research_rate: 0.4
    apply: (element, build_only) ->
      icons.toggleable element, "ronald_regan"
  }
  { -- 19 SCP self-defense sugar
    trigger: {scp: 0.25}
    icon: "icons/amphora.png"
    tooltip: "SCP-989 \"Self-Defense Sugar\""
    apply: (element, build_only) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
        return true
  }
  { -- 20 SCP the director's cut
    trigger: {scp: 0.25}
    icon: "icons/salt-shaker.png"
    tooltip: "SCP-981 \"The Director's Cut\""
    apply: (element, build_only) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
        return true
  }
  { -- 21 SCP desert in a can
    trigger: {scp: 0.006, multiple: true}
    icon: "icons/spray.png"
    tooltip: "An instance of SCP-622 \"Desert in a Can\"\n${cash_rate} containment cost\n(click to hide)"
    cash_rate: -0.28
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          element\delete!
        elseif button == pop.constants.right_mouse
          icons.scp_info element
        return true
  }
  { -- 22 SCP book of endings
    trigger: {scp: 0.20}
    icon: "icons/death-note.png"
    tooltip: "SCP-152 \"Book of Endings\"\n${cash_rate} research cost, ${research_rate}"
    cash_rate: -7.5
    research_rate: 5
    apply: (element, build_only) ->
      icons.toggleable element, "book_of_endings"
  }
  { -- 23 SCP diet ghost
    trigger: {scp: 0.002, multiple: true}
    icon: "icons/soda-can.png"
    tooltip: "An instance of SCP-2107 \"Diet Ghost\"\n${cash_rate} containment cost\n(click to hide)"
    cash_rate: -0.26
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          element\delete!
        elseif button == pop.constants.right_mouse
          icons.scp_info element
        return true
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
        return true
  }
  { -- 25 the clockworks
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
        return true
  }
  { -- 26 clockwork-caused breach
    trigger: {random: 0.001/60, multiple: true} -- no idea what rate this is
    icon: "icons/clockwork.png"
    tooltip: "Containment breach caused by SCP-914!\n${cash_rate} until contained, ${danger_rate} until contained\n${cash} to attempt containment"
    tip: "Breaches can escalate danger and cause a loss pretty quickly. Be wary, and stop them quickly."
    tipOnce: true
    cash_rate: -40
    danger_rate: 1.5
    cash: -10000
    apply: (element, build_only) ->
      unless build_only
        if data.cleared_scps[25] -- if the SCP has been found
          data.cash_rate += element.data.cash_rate
          data.danger_rate += element.data.danger_rate
        else
          element\delete!
          return false --cancel, we don't have it
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.cash_rate -= element.data.cash_rate
            data.danger_rate -= element.data.danger_rate
            element\delete!
        return true
  }
  { -- 27 SCP best of the 5th dimension
    trigger: {random: 0.01/60}   -- 1% per minute
    icon: "icons/compact-disc.png"
    tooltip: "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n0/3125 disks researched, ${cash} research cost, ${research}\n(click to research)"
    cash: -15
    research: 10
    apply: (element, build_only) ->
      update_cash = ->
        icons[27].cash = -(1.05 * (data.scp092_researched_count + 625) ^ 0.65 + 1.05 ^ (data.scp092_researched_count / 25) - 55)
      update_cash!
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.scp092_researched_count < 3124 and data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.research += element.data.research
            data.scp092_researched_count += 1
            update_cash!
            if data.scp092_researched_count == 3125
              element.data.tooltip = "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n3125/3125 disks researched"
            else
              element.data.tooltip = "SCP-092 \"The Absolute Absolute Absolute Absolute BEST of The 5th Dimension!!!!!\"\n#{data.scp092_researched_count}/3125 disks researched, ${cash} research cost, ${research}\n(click to research)"
        elseif button == pop.constants.right_mouse
          icons.scp_info element
        return true
  }
  { -- 28 SCP deathly video tape
    trigger: {scp: 0.4}
    icon: "icons/audio-cassette.png"
    tooltip: "SCP-583 \"Deathly Video Tape\"\n${cash_rate} containment cost, ${research}"
    cash: -0.15
    research: 4
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.research += element.data.research
      element.clicked = (x, y, button) =>
        if button == pop.constants.right_mouse
          icons.scp_info element
  }
  --TODO make expeditions have a failure rate that increases as more SCPs are discovered
  --TODO make a breach of SCP-622 (desert in a can) that is extremely costly to contain, and dangerous when uncontained
  --     THIS BREACH CAN ONLY TRIGGER WHEN USING THE RESEARCH SCPs BUTTON !!
  --TODO make a research policy that can trigger breach of SCP-622, but gives constant research and danger based on SCP count (automated version of the research SCPs button basically)
  --TODO make a Class D termination policy that when active reduces danger but increases cost on a regularly timed basis
  --     it also fluctuates the count of Class D personnel by randomly clicking hire / unhire, using a sine function to make a steady curve
  --TODO make a vault icon that is used when you have more than 5 SCPs that is needed to contain more SCPs (build site)
  --{
    --trigger: {cash: 16000}
    -- a better source of income is needed
  --}
  --TODO getting and terminating class D's should be in 5's
  --      adjust values to represent five and increase/decrease by five (if can't for some reason, decrease by however many can)
}

for i=1, #icons
  icons[i].id = i

for id, description in pairs descriptions
  icons[id].description = description[1]

return icons
