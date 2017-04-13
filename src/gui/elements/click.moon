import random from require "lib.lume"
import graphics from love

icons = require "icons"
state = require "state"

text = require "lib/pop/elements/text"

class click extends text
  new: (...) =>
    super ...

    @data.type = "click"
    @data.lifetime = 1.5
    @data.hoverable = false
    @data.focusable = false --TODO make this a feature of Pop.Box!

    -- these are not functional
    --@data.x += random -6, 6
    --@data.y += random -12, -2
    @data.offset = random()

    @setText "-click-"

  draw: =>
    graphics.setColor 0, 0, 0, 255
    graphics.rectangle "fill", @data.x, @data.y, @data.w, @data.h

    super!

  update: (dt) =>
    @data.lifetime -= dt
    if @data.lifetime <= 0
      @delete!
      return

    @move math.sin((@data.lifetime + @data.offset) * 5) / 1.75, random(-35 * dt, -30 * dt)
