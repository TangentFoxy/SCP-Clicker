{ -- 14 SCP MalO (never be alone)
  trigger: {scp: 0.001, multiple: true}
  icon: "icons/smartphone.png"
  tooltip: "SCP-1471 (MalO ver1.0.0)\n${cash_rate} containment cost per instance, ${research} per instance"
  cash_rate: -0.3
  research: 6
  apply: (element, build_only) ->
    icons.multiple_scp element, build_only
}
