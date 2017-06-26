{ -- 18 SCP RONALD REGAN CUT UP WHILE TALKING
  trigger: {scp: 0.15}
  icon: "icons/video-camera.png"
  tooltip: "SCP-1981 \"RONALD REGAN CUT UP WHILE TALKING\"\n${cash_rate} research cost, ${research_rate}\n(click to research)"
  cash_rate: -6.2
  research_rate: 0.4
  apply: (element, build_only) ->
    icons.toggleable_scp element, "ronald_regan"
}
