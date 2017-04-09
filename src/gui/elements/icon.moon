import graphics from love

element = require "lib/pop/elements/element"

class icon extends element
  new: (@parent, @data={}, icon="") =>
    super @parent, @data

    @data.icon = icon unless @data.icon

    @icon = graphics.newImage @data.icon

    @data.w = @icon\getWidth! if not @data.w or @data.w == 0
    @data.h = @icon\getHeight! if not @data.h or @data.h == 0

    @scaleX = @data.w / @icon\getWidth!
    @scaleY = @data.h / @icon\getHeight!

  draw: =>
    graphics.setColor 255, 255, 255, 255
    graphics.draw @icon, @data.x, @data.y, 0, @scaleX, @scaleY
