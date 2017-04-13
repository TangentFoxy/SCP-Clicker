import graphics from love

icons = require "icons"

element = require "lib/pop/elements/element"

class icon extends element
  new: (@parent, @data={}, icon="") =>
    super @parent, @data

    @data.type = "icon"
    @data.icon = icon unless @data.icon

    @icon = graphics.newImage @data.icon

    @data.w = @icon\getWidth! if not @data.w or @data.w == 0
    @data.h = @icon\getHeight! if not @data.h or @data.h == 0

    @scaleX = @data.w / @icon\getWidth!
    @scaleY = @data.h / @icon\getHeight!

  draw: =>
    graphics.setColor 255, 255, 255, 255
    graphics.rectangle "fill", @data.x, @data.y, @data.w, @data.h -- lazy way of making transparency -> white
    graphics.draw @icon, @data.x, @data.y, 0, @scaleX, @scaleY

    return @

  setIcon: (icon) =>
    @data.icon = icon
    @icon = graphics.newImage @data.icon

    return @

  debugInfo: =>
    return @data.id

  delete: =>
    super @

    icons.fix_order!
