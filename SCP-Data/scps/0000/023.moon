{
  tab: "SCPs"
  type: "SCP"
  id: "SCP-023"
  title: "Black Shuck"
  icon: love.graphics.newImage("icons/wolf-head.png")
  -- tooltip: "" containment cost ?
  description: [[SCP-023 is a large, sexless shaggy canine (1.5 meters at the shoulder) with black fur. It has bright orange-red eyes and prominent teeth. Any time an individual makes eye contact with SCP-023, either that person or a member of their immediate family will die exactly one (1) year after eye contact is broken. Research into the method of selection is incomplete due to a moratorium on experiments, but the available data suggests that having a larger immediate family lessens the chance of the individual making eye contact themselves dying, and neither a pattern nor a preference in victim types have been found. This may indicate that SCP-023's victim is designated entirely at random, but it is unknown whether this selection occurs at the beginning or at the end of the one-year time period. Attempts to terminate an individual who has made eye contact with SCP-023 and their entire immediate family before the one-year time period has ended [DATA EXPUNGED].
  .
  Autopsies of individuals killed by SCP-023's effect show that, while outwardly appearing unharmed, their remains have been 'filled in' with highly compacted ash, including but not limited to all organ systems and the circulatory system. Muscle tissue, bones, and brain tissue universally show signs of exposure to temperatures above ██°C.]]
  related: {
    "SCP-293"
    "Incident 023-01"
    -- "SCP-1111-1" -- possibly, not sure if should be included here
  }
  triggers: {
    chance: 0.42
  }
  containment: {} -- undefined
  experimentation: "allowed" -- TODO check this
  cost: {
    -- initial: 20 -- should be handled by method of obtaining it?
    ongoing: 5 -- shouldn't this be handled by it using a standard cell, the upkeep of the cell ?
  }

  alive: true
  animal: true
  canine: true
  cognitohazard: true
  euclid: true
  fire: true
  intangible: true
  sun: true
  teleportation: true
}
