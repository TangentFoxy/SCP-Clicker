{ -- 23 SCP diet ghost
  trigger: {scp: 0.002, multiple: true}
  icon: "icons/soda-can.png"
  tooltip: "SCP-2107 \"Diet Ghost\"\n${cash_rate} containment cost per instance"
  cash_rate: -0.26
  apply: (element, build_only) ->
    icons.multiple_scp element, build_only
}
