{
  tab: "SCPs"
  type: "SCP"
  id: "SCP-023"
  title: "The Plague Doctor"
  icon: love.graphics.newImage("icons/plague-doctor-profile.png")
  -- tooltip: "containment cost"
  description: [[SCP-049 is humanoid in appearance, standing at 1.9 m tall and weighing 95.3 kg; however, the Foundation is currently incapable of studying its face and body more fully, as it is covered in what appears to be the garb of the traditional “Plague Doctor” from 15-16th century Europe. This material is actually a part of SCP-049’s body, as microscopic and genetic testing show it to be similar in structure to muscle, although it feels much like rough leather, and the mask much like ceramic. It was originally discovered in ██████, England, by local police. Mobile task force [REDACTED] responded to a suspected outbreak of [DATA EXPUNGED]. All civilians within a .5km radius were given class A amnestics as part of the initial containment procedure.
  .
  SCP-049 does not usually speak (See addendum A-1), although it seems to understand English perfectly well, and is completely docile until it tries to perform surgery. SCP-049’s touch is invariably lethal to humans. After contact with SCP-049’s hand(s), the victim (hereafter referred to as SCP-049-2) suffers [DATA EXPUNGED] and dies within moments. SCP-049 will then attempt to kill all humans it can see in a similar manner, supposedly to avoid interruption, before returning to SCP-049-2. It produces a bag made of [DATA EXPUNGED] containing scalpels, needle, thread, and several vials of an as-yet-unidentified substance, from somewhere within its body (research has been unable to locate these tools when inside of SCP-049 through X-ray and similar techniques) and begins dissecting SCP-049-2, as well as inserting various chemicals into the body. After approximately 20 minutes, SCP-049 will sew SCP-049-2 back up and become docile once more.
  .
  After a period of a few minutes, SCP-049-2 will resume vital signs and appears to reanimate. However, SCP-049-2 seems completely without higher brain functions, and will wander aimlessly until it encounters another living human. At that point, SCP-049-2's adrenaline and endorphin levels increase to approximately three-hundred (300) percent as it attempts to kill and ██████ any human beings it can find, before returning to its mindless state and wandering until it comes across more humans. At this stage, termination with extreme prejudice is allowed. Failure to enforce this protocol outside of testing scenarios (see addendum T-049-12) is punishable by termination.
  .
  Detailed autopsies of SCP-049-2 have found several unusual substances (along with usual substances in large amounts) within the bodies, including [DATA EXPUNGED]. However, several have yet to be identified.]]
  triggers: {
    chance: 0.10
  }
  containment: {} -- undefined
  experimentation: "allowed" -- TODO check this

  cost: {
    ongoing: 2.5
  }
  -- research rate ? or research value ?

  biological: true
  chemical: true
  contagion: true
  euclid: true
  humanoid: true
  reanimation: true
  sapient: true
  sentient: true
  tactile: true
}
