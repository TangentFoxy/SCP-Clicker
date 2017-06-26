{ -- 39 SCP broken spybot
  trigger: {scp: 0.3}
  icon: "icons/metal-disc.png"
  tooltip: "SCP-1599 \"Broken Spybot\"\n${cash_rate} research cost, ${research_rate}"
  cash_rate: -8.4
  research_rate: 5.2
  apply: (element, build_only) ->
    icons.toggleable_scp element, "broken_spybot"
}
