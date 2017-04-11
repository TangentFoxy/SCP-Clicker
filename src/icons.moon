import round, weightedchoice from require "lib.lume"

pop = require "lib.pop"
data = require "data"
timers = require "timers"

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

  replace: (data) ->
    s = data.tooltip
    tbl = {}

    tbl.cash = icons.format_cash data.cash if data.cash
    tbl.research = icons.format_research data.research if data.research
    tbl.danger = icons.format_danger data.danger if data.danger
    tbl.time = icons.format_time data.time if data.time

    tbl.cash_rate = icons.format_cash_rate data.cash_rate if data.cash_rate
    tbl.research_rate = icons.format_research_rate data.research_rate if data.research_rate
    tbl.danger_rate = icons.format_danger_rate data.danger_rate if data.danger_rate

    tbl.cash_multiplier = icons.format_cash_multiplier data.cash_multiplier if data.cash_multiplier

    (s\gsub('($%b{})', (w) -> tbl[w\sub(3, -2)] or w))

  choose_scp: ->
    tbl = {}
    for key, icon in ipairs icons
      if icon.trigger.scp
        tbl[key] = icon.trigger.scp
    scp = icons[weightedchoice tbl]
    unless scp.trigger.multiple
      scp.trigger.scp = nil
      table.insert data.cleared_scps, scp.id
    data.scp_count += 1
    return scp

  basic: (element) ->
    element.clicked = (x, y, button) =>
      if button == pop.constants.left_mouse
        data.cash += element.data.cash if element.data.cash
        data.research += element.data.research if element.data.research
        data.danger += element.data.danger if element.data.danger
      return true

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
    tooltip: "Research contained SCPs.\n${research} per SCP, ${danger} per SCP"
    research: 1
    danger: 2
    apply: (element) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          data.research += element.data.research * data.scp_count
          data.danger += element.data.danger * data.scp_count
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
  { -- 4
    trigger: {}
    icon: "icons/pentagram-rose.png"
    tooltip: "Use Class D personnel to complete containment rituals.\n${cash}, ${danger}"
    cash: -80
    danger: -6
    apply: (element) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs(element.data.cash) and data.danger > 0.1
            data.cash += element.data.cash
            data.danger += element.data.danger
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
        element\delete!
        return true
  }
  { -- 8 agent deaths
    trigger: {random: 0.8/60, multiple: true} -- 0.8% chance per minute intended, seems to be per second
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
    tooltip: "(INACTIVE) Hire replacement agents automatically.\n${cash_rate}"
    cash_rate: -4
    update: false -- inactive by default
    apply: (element) ->
      element.data.agent_count = data.agent_count
      element.update = =>
        if data.agent_count < element.data.agent_count
          data.cash_rate += icons[5].cash_rate
          data.danger_rate += icons[5].danger_rate
          data.agent_count += 1
        elseif data.agent_count > element.data.agent_count
          element.data.agent_count = data.agent_count
      if data.agent_rehire_enabled
        element.data.update = true
        element\setIcon "icons/hammer-sickle-inverted.png"
        element.data.tooltip = "(ACTIVE) Hire replacement agents automatically.\n${cash_rate}"
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          -- if turning off, or have cash to turn on
          if not element.data.update or data.cash >= math.abs(element.data.cash_rate)
            element.data.update = not element.data.update
            if element.data.update
              data.cash_rate += element.data.cash_rate
              element\setIcon "icons/hammer-sickle-inverted.png"
              element.data.tooltip = "(ACTIVE) Hire replacement agents automatically.\n${cash_rate}"
              data.agent_rehire_enabled = true
              element.data.agent_count = data.agent_count
            else
              data.cash_rate -= element.data.cash_rate
              element\setIcon "icons/hammer-sickle.png"
              element.data.tooltip = "(INACTIVE) Hire replacement agents automatically.\n${cash_rate}"
              data.agent_rehire_enabled = false
        return true
  }
  { -- 10 open banks
    trigger: {savings_accounts: 20}
    icon: "icons/bank.png"
    tooltip: "Open a bank.\n${cash}, ${cash_multiplier} (maximum +$500/s cash)"
    cash: -6000
    cash_multiplier: 1/100
    apply: (element) ->
      bg = pop.box(element)\align "left", "bottom"
      fg = pop.text(bg, 20)\setColor 255, 255, 255, 255
      fg.update = =>
        fg\setText data.bank_count
        bg\setSize fg\getSize!
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
  }
  { -- 14 SCP never be alone
    trigger: {scp: 0.001, multiple: true}
    icon: "icons/smartphone.png"
    tooltip: "SCP-1471 (MalO ver1.0.0)\n${cash_rate} containment cost, ${research}\n(click to hide)"
    cash_rate: -0.3
    research: 6
    apply: (element, build_only) ->
      unless build_only
        data.cash_rate += element.data.cash_rate
        data.research += element.data.research
      element.clicked = (x, y, button) =>
        element\delete!
        return true
  }
  --{
    --trigger: {cash: 16000}
    -- a better source of income is needed
  --}
}

for i=1, #icons
  icons[i].id = i

return icons
