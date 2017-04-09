import graphics from love

element = require "lib/pop/elements/element"

class box extends element
  new: (@parent, @data={}, w, h) =>
    super @parent, @data

    unless @data.color
      @data.color = {0, 0, 0, 255}

    if w
      @data.w = w if @data.w == 0
    if h
      @data.h = h if @data.h == 0

  draw: =>
    graphics.setColor @data.color
    graphics.rectangle "fill", @data.x, @data.y, @data.w, @data.h

  --- Change box color. Uses LOVE's 0-255 values for components of colors.
  --- @tparam ?number|table r The red component or a table of RGBA values.
  --- @tparam number g The green component.
  --- @tparam number b The blue component.
  --- @tparam number a The alpha component. While not technically required, if
  --- ANYTHING uses an alpha component and you don't, it could cause bugs in
  --- rendering.
  --- @treturn element self
  setColor: (r, g, b, a) =>
      if "table" == type r
          @data.color = r
      else
          @data.color = {r, g, b, a}
      return @
