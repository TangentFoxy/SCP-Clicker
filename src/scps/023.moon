{ -- 43 SCP black shuck
  trigger: {scp: 0.42}
  icon: "icons/wolf-head.png"
  tooltip: "SCP-023 \"Black Shuck\"\n${cash_rate} containment cost"
  cash_rate: -8.5
  apply: (element, build_only) ->
    icons.basic_scp element
}
