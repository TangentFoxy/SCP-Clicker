import round from require "lib.lume"

pop = require "lib.pop"
data = require "data"

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

  replace: (data) ->
    s = data.tooltip
    tbl = {}
    tbl.cash = icons.format_cash data.cash if data.cash
    tbl.research = icons.format_research data.research if data.research
    tbl.danger = icons.format_danger data.danger if data.danger
    tbl.cash_rate = icons.format_cash_rate data.cash_rate if data.cash_rate
    tbl.research_rate = icons.format_research_rate data.research_rate if data.research_rate
    tbl.danger_rate = icons.format_danger_rate data.danger_rate if data.danger_rate
    (s\gsub('($%b{})', (w) -> tbl[w\sub(3, -2)] or w))

  basic: (element) ->
    element.clicked = (x, y, button) =>
      if button == pop.constants.left_mouse
        data.cash += element.data.cash if element.data.cash
        data.research += element.data.research if element.data.research
        data.danger += element.data.danger if element.data.danger

  {
    trigger: {danger: 0.022}
    icon: "icons/banknote.png"
    tooltip: "Get funds.\n${cash}, ${danger}"
    cash: 100
    danger: 0.2
    apply: (element) ->
      icons.basic element
  }
  {
    trigger: {}
    icon: "icons/soap-experiment.png"
    tooltip: "Research contained SCPs.\n${research}, ${danger}"
    research: 1
    danger: 10
    apply: (element) ->
      icons.basic element
  }
  {
    trigger: {cash: 800}
    icon: "icons/piggy-bank.png"
    tooltip: "Open a savings account.\n${cash}, ${cash_rate}"
    cash: -800
    cash_rate: 1
    apply: (element) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs element.data.cash
            data.cash += element.data.cash
            data.cash_rate += element.data.cash_rate
  }
  {
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
  }
  {
    trigger: {danger: 0.1}
    icon: "icons/person.png"
    tooltip: "Hire an agent.\n${cash_rate}, ${danger_rate}"
    cash_rate: -1.2
    danger_rate: -0.05
    apply: (element) ->
      element.clicked = (x, y, button) =>
        if button == pop.constants.left_mouse
          if data.cash >= math.abs(element.data.cash_rate)
            data.cash_rate += element.data.cash_rate
            data.danger_rate += element.data.danger_rate
  }
}

return icons
