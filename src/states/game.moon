pop = require "lib.pop"
settings = require "settings"

import graphics from love

game = {}

game.init = =>
  pop.load "gui"
  -- pop.tabs alignHorizontal: 1/3, h: graphics.getHeight!

game.update = (dt) =>
  pop.update dt

game.draw = =>
  pop.draw!
  pop.debugDraw! if settings.debug

game.mousemoved = (x, y, dx, dy) =>
  pop.mousemoved x, y, dx, dy

game.mousepressed = (x, y, button) =>
  pop.mousepressed x, y, button

game.mousereleased = (x, y, button) =>
  pop.mousereleased x, y, button

game.wheelmoved = (x, y) =>
  pop.wheelmoved x, y

game.keypressed = (key) =>
  if key == "d"
    settings.debug = not settings.debug

return game
