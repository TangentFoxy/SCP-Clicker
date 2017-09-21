{
  tab: "SCPs"
  type: "SCP"
  id: "SCP-035"
  title: "Possessive Mask"
  icon: love.graphics.newImage("icons/duality-mask.png")
  -- tooltip: "" containment cost
  description: [[SCP-035 appears to be a white porcelain comedy mask, although, at times, it will change to tragedy. In these events, all existing visual records, such as photographs, video footage, even illustrations, of SCP-035 automatically change to reflect its new appearance.
  .
  A highly corrosive and degenerative viscous liquid constantly seeps from the eye and mouth holes of SCP-035. Anything coming into contact with this substance slowly decays over a period of time, depending on the material, until it has decayed completely into a pool of the original contaminant. Glass seems to react the slowest to the effects of the item, hence the construction choice of its immediate container. Living organisms that come into contact with the substance react much the same way, with no chance of recovery. Origin of the liquid is unknown. Liquid is only visible from the front, and does not emerge or is even visible from the other side.
  .
  Subjects within 1.5 to 2 meters (5-6 feet) of SCP-035, or in visual contact with it, experience a strong urge to put it on. When SCP-035 is placed on the face of an individual, an alternate brain wave pattern from SCP-035 overlaps that of the original host, effectively snuffing it out and causing brain death to the subject. Subject then claims to be the consciousness contained within SCP-035. The bodies of "possessed" subjects decay at a highly accelerated rate, eventually becoming little more than mummified corpses. Nevertheless, SCP-035 has demonstrated the ability to remain in cognitive control of a body experiencing severe structural damage, even if the subject's body literally decays to the point where motion is not mechanically possible. No effect is found to be had when placed on the face of an animal.
  .
  Conversations with SCP-035 have proven to be informative. Researchers have learned various details about other SCP objects and history in general, as SCP-035 claims to have been at many momentous events. SCP-035 displays a highly intelligent and charismatic personality, being both amiable and flattering to all those who speak with it. SCP-035 has scored in the 99th percentile on all intelligence and aptitude tests administered to it, and appears to have a photographic memory.
  .
  However, psychological analysis has discovered SCP-035 to possess a highly manipulative nature, capable of forcing sudden and profound changes to interviewer's psychological state. SCP-035 has proven to be highly sadistic, prompting some to commit suicide and transforming others into near-mindless servants with linguistic persuasion alone. SCP-035 has stated that it has intimate knowledge of the workings of the human mind and implied that it could change anyone's views if given enough time.]]
  triggers: {
    chance: 0.03
  }
  containment: {}
  experimentation: "allowed" -- TODO check this
  cost: {
    ongoing: 15
  }

  clothing: true
  cognitohazard: true
  ectoentropic: true
  keter: true
  'mind-affecting': true
  sapient: true
  sentient: true
  telepathic: true
}
