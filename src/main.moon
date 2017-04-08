pop = require "lib.pop"

love.load = ->
  love.graphics.setBackgroundColor 255, 255, 255, 255

  pop.load "gui"

  pop.text("Hello World!")\align "center", "center"
  pop.icon({
    w: 128, h: 128
    icon: "icons/soap-experiment.png"
  })\move 123, 234

love.update = (dt) ->
  pop.update dt

love.draw = ->
  pop.draw!
  pop.debugDraw!

love.mousemoved = (x, y, dx, dy) ->
  pop.mousemoved x, y, dx, dy

love.mousepressed = (x, y, button) ->
  pop.mousepressed x, y, button

love.mousereleased = (x, y, button) ->
  pop.mousereleased x, y, button

love.keypressed = (key) ->
  unless pop.keypressed key
    if key == "escape"
      love.event.quit!

love.keyreleased = (key) ->
  pop.keyreleased key

love.textinput = (text) ->
  pop.textinput text
