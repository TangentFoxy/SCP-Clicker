{ -- 44 SCP the darkest heart
  trigger: {scp: 0.02}
  icon: "icons/tentacle-heart.png"
  tooltip: "SCP-058 \"The Darkest Heart\"\n${cash_rate} containment cost"
  cash_rate: -28
  apply: (element, build_only) ->
    icons.basic_scp element
}
