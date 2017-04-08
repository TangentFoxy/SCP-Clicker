-- all details are optional!

local items
items = {
  {
    name: "The Broken Desert" -- a nickname used in conjunction with ID
    chance: 0.002 -- how likely the object is to be discovered (default 1% if not specified)
    danger: 0.01 -- between 0 and 1
    multiple: true -- can be discovered multiple times
    found: { -- reports for initial discovery
      "In ${state}, a small glass pyramid containing sand was recovered. The sand shows evidence of a dust storm, and material appears to blow in and out of the terrain within."
      "On the coast of ${country}, a trigular structure containing what appears to be a desert was discovered. Within the structure, there is a scorpian that appears healthy."
      "Within ${region}, ${small_int} small glass pyramids were discovered. Each contains sand and features consistent with a desert. They seem to be unaffected by the outside world.": {count: "${small_int}"}
    }
    found_again: { -- appended to report when found again
      "This appears to be another instance of ${id}."
      "Definitely another piece of the broken desert."
      "Don't we have a room full of these already?"
      "Part of ${id}."
      "An instance of ${id}. I suggest we start keeping these at multiple sites."
    }
    research_minor: {
      -- anomalous properities discovered while in containment during basic research
      --  (each can only be found once, and are saved as discovered)
      "A scorpian, earlier within ${sub_id}, has since moved out of and into ${sub_id}. The pieces appear to be part of a combined whole. Anything within them can move between pieces at will.": {requires: {count: 2}}
      "A storm has been spotted moving through multiple instances of ${id}. First spotted in ${sub_id}.": {requires: {count: 3}}
      "A lizard was spotted inside ${id}. It is not known how the lizard got inside the object.": {requires: {exact_count: 1}}
    }
    breach: { -- report when it breaches containment
      "A member of the cleaning staff dropped an instance of ${id}. The sand within spilled into the storage room.": {
        requires: {count: 2}
        damage: 0.01
        resolve_time: 0
      }
      "The object was broken by a member of cleaning staff. They have since been retired. A cactus was recovered from the object and is being studied.": {
        requires: {exact_count: 1}
        damage: 0.01
        resolve_time: 0
      }
    }
  }
}

return items
