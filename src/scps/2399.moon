{ -- 46 SCP malfunctioning destroyer (Jupiter)
  trigger: {random: 0.01/60} -- 1% chance per minute
  icon: "icons/jupiter.png"
  tooltip: "SCP-2399 \"A Malfunctioning Destroyer\"\n${cash_rate} containment cost"
  cash_rate: -60
  apply: (element, build_only) ->
    icons.basic_scp element
}
