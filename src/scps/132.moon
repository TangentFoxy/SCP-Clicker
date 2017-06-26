{ -- 7 SCP the broken desert
  trigger: {scp: 0.01, multiple: true} -- 1% chance of being chosen
  icon: "icons/cracked-glass.png"
  tooltip: "SCP-132 \"The Broken Desert\"\n${cash_rate} containment cost per instance, ${research} per instance"
  cash_rate: -0.2
  research: 4
  apply: (element, build_only) ->
    icons.multiple_scp element, build_only
}
