{ -- 42 SCP to end all wars
  trigger: {scp: 0.01}
  icon: "icons/gas-mask.png"
  tooltip: "SCP-186 \"To End All Wars\"\n${cash_rate} containment cost"
  cash_rate: -32
  apply: (element, build_only) ->
    icons.basic_scp element
}
