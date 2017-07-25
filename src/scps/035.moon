{ -- 41 SCP comedy mask
  trigger: {scp: 0.03}
  icon: "icons/duality-mask.png"
  tooltip: "SCP-035 \"Possessive Mask\"\n${cash_rate} containment cost"
  cash_rate: -15
  apply: (element, build_only) ->
    icons.basic_scp element
}
