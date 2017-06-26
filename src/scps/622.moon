{ -- 21 SCP desert in a can
  trigger: {scp: 0.006, multiple: true}
  icon: "icons/spray.png"
  tooltip: "SCP-622 \"Desert in a Can\"\n${cash_rate} containment cost per instance"
  cash_rate: -0.28
  apply: (element, build_only) ->
    icons.multiple_scp element, build_only
}
