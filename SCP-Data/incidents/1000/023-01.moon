{
  tab: "Incidents"
  type: "incident"
  id: "Incident 023-01"
  -- no title
  -- icon
  description: [[SCP-023 broke containment on ██/██/████ by passing through its cell wall. SCP-023 was later discovered at the intersection of two (2) corridors elsewhere on Site-███. Agent █████ noted SCP-023's similarity to a [REDACTED]. Special Containment Procedures for SCP-023 updated. Assistant Researcher ███████ issued a reprimand for negligence.]]
  related: {
    "SCP-023"
  }
  triggers: {}
  -- containment: {
  --   resolved: true
  -- }
  cost: {
    initial: 75
    ongoing: 4.2
    time: 2*60
  }
  -- status: "resolved"
  effect: {
    target: "SCP-023"
    description: [[SCP-023 is a large, sexless shaggy canine (1.5 meters at the shoulder) with black fur. It has bright orange-red eyes and prominent teeth. Any time an individual makes eye contact with SCP-023, either that person or a member of their immediate family will die exactly one (1) year after eye contact is broken. Research into the method of selection is incomplete due to a moratorium on experiments, but the available data suggests that having a larger immediate family lessens the chance of the individual making eye contact themselves dying, and neither a pattern nor a preference in victim types have been found. This may indicate that SCP-023's victim is designated entirely at random, but it is unknown whether this selection occurs at the beginning or at the end of the one-year time period. Attempts to terminate an individual who has made eye contact with SCP-023 and their entire immediate family before the one-year time period has ended [DATA EXPUNGED].
    .
    Autopsies of individuals killed by SCP-023's effect show that, while outwardly appearing unharmed, their remains have been 'filled in' with highly compacted ash, including but not limited to all organ systems and the circulatory system. Muscle tissue, bones, and brain tissue universally show signs of exposure to temperatures above ██°C.
    .
    If not contained in a setting that at least superficially resembles a "crossroads", SCP-023 will phase through walls to get to the nearest suitable location, incinerating all materials it passes through.]]
    cost: {
      ongoing: 8.5
    }
  }

  breach: true
  -- resolved: true
}
