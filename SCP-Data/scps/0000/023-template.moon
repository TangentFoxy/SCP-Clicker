{
  tab: "SCPs"        -- UI tab
  icon: love.graphics.newImage('some/file.png')
  description: "blah blah blah"
  tip: "undefined str format" -- todo, use substitution so dynamically set when called for
  id: "SCP-023"
  related: {
    "SCP-293"
    "Incident 023-1"
    -- etc
  }

  type: "SCP"
  trigger: {
    -- undefined / reusing others
  }
  containment: {
    -- undefined
  }
  experimentation: "allowed" -- or "denied" or "complete" (very rare)
  cost: {
    initial: 5       -- applied once and deleted
    incremental: 0.5 -- per second
    multiplier: 1    -- useless when 1
    time: 500        -- how many seconds will last
  }
  memtic: true       -- tag
  data: {
    -- undefined
  }
}
