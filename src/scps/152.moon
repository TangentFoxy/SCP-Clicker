{ -- 22 SCP book of endings
  trigger: {scp: 0.20}
  icon: "icons/death-note.png"
  tooltip: "SCP-152 \"Book of Endings\"\n${cash_rate} research cost, ${research_rate}"
  cash_rate: -7.5
  research_rate: 5
  apply: (element, build_only) ->
    icons.toggleable_scp element, "book_of_endings"
}
