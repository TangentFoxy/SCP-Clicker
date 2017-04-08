math.randomseed(os.time())
require "lib.gooi" -- fuck you module creator, this is bad design

for key, value in pairs(gooi) do
  print(key, value)
end

function love.load()
  love.graphics.setBackgroundColor(255, 255, 255, 255)

  gooi.setStyle{
    bgColor = {0, 0, 0, 255},
    fgColor = {255, 255, 255, 255}
  }

  --[[
  report = gooi.newLabel{align = "left", x = 100, y = 100, w = 300, h = 32}:setOpaque(true)
  report:setText("Lorem ipsum solor det amet. El tiago, set dashmere valor en espan.\nDonka, est verd al begonau el synchro motion value on est vamir.")
  --]]

  --[[
  panel = gooi.newPanel(0, 0, love.graphics.getWidth(), love.graphics.getHeight(), "grid 4x4")
  panel:setRowspan(1, 2, 2)
  panel:setColspan(1, 2, 3)
  panel:add(
    gooi.newButton("Generate Report"):onRelease(function()
      report:setText("Lorem ipsum solor det amet. El tiago, set dashmere valor en espan.\nDonka, est verd al begonau el synchro motion value on est vamir.")
    end),
    report
  )
  --]]

  text = gooi.newText("Last Button")
  text:setText(tostring(text.w))

  panelGrid = gooi.newPanel(0, 0, 380, 150, "grid 4x4") -- x, y, w, h, layout
	panelGrid:setRowspan(1, 1, 2)
	panelGrid:setColspan(4, 3, 2)
	panelGrid:add(
		gooi.newButton("Fat Button"),
		gooi.newButton("Button 1"),
		gooi.newButton("Button 2"),
		gooi.newButton("Button 3"),
		gooi.newButton("Button X"),
		gooi.newButton("Button Y"),
		gooi.newButton("Button Z"),
		gooi.newButton("Button ."),
		gooi.newButton("Button .."),
		gooi.newButton("Button ..."),
		gooi.newButton("Button ...."),
		text,
		gooi.newCheck("Check 1"),
		gooi.newCheck("Large Check")
	)
end

function love.update(dt)
  gooi.update(dt)
end

function love.draw()
  gooi.draw()

  --temporary
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.line(text.x + 9, text.y + 9, text.x + text.w - 9, text.y + text.h - 9)
end

function love.mousepressed() gooi.pressed() end
function love.mousereleased() gooi.released() end

function love.touchpressed(id, x, y) gooi.pressed(id, x, y) end
function love.touchreleased(id, x, y) gooi.released(id, x, y) end
function love.touchmoved(id, x, y) gooi.moved(id, x, y) end

-- temporary, for debug purposes
function love.keypressed(key)
  if not gooi.keypressed(key) then
    if key == "escape" then
      love.event.quit()
    end
  end
end

function love.textinput(text)
  gooi.textinput(text)
end
