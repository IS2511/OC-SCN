local component = require("component")
local term = require("term")
local colors = require("colors")
gpu = component.gpu

local w, h = gpu.getResolution()  -- Gets screen getResolution

local w1x1 = 2
local w1x2 = w / 2 - 1
local w1y1 = 1
local w1y2 = h / 4 * 3 - 3

local w2x1 = w / 2 + 1
local w2x2 = w - 2
local w2y1 = 1
local w2y2 = h / 4 * 3 - 3

local w3x1 = 2
local w3x2 = w / 4 * 3 - 3
local w3y1 = h / 4 * 3
local w3y2 = h - 1

local w4x1 = w / 4 * 3 - 1
local w4x2 = w - 2
local w4y1 = h / 4 * 3
local w4y2 = h - 1




--term.clear()

function drawWindows()    -- Rendering gui form

  -- Window 1
  gpu.set(w1x1, w1y1, "╔")
  gpu.set(w1x2, w1y1, "╗")
  gpu.set(w1x1, w1y2, "╚")
  gpu.set(w1x2, w1y2, "╝")

  gpu.fill(w1x1 + 1, w1y1, w1x2 - w1x1 - 1, 1, "═")
  gpu.fill(w1x1, w1y1 + 1, 1, w1y2 - w2y1 - 1, "║")
  gpu.fill(w1x2, w1y1 + 1, 1, w1y2 - w2y1 - 1, "║")
  gpu.fill(w1x1 + 1, w1y2, w1x2 - w1x1 - 1, 1, "═")

  -- Window 2
  gpu.set(w2x1, w2y1, "╔")
  gpu.set(w2x2, w2y1, "╗")
  gpu.set(w2x1, w2y2, "╚")
  gpu.set(w2x2, w2y2, "╝")

  gpu.fill(w2x1 + 1, w2y1, w2x2 - w2x1 - 1, 1, "═")
  gpu.fill(w2x1, w2y1 + 1, 1, w2y2 - w2y1 - 1, "║")
  gpu.fill(w2x2, w2y1 + 1, 1, w2y2 - w2y1 - 1, "║")
  gpu.fill(w2x1 + 1, w2y2, w2x2 - w2x1 - 1, 1, "═")

  -- Window 3
  gpu.set(w3x1, w3y1, "╔")
  gpu.set(w3x2, w3y1, "╗")
  gpu.set(w3x1, w3y2, "╚")
  gpu.set(w3x2, w3y2, "╝")

  gpu.fill(w3x1 + 1, w3y1, w3x2 - 3, 1, "═")
  gpu.fill(w3x1, w3y1 + 1, 1, (h / 4) - 1, "║")
  gpu.fill(w3x2, w3y1 + 1, 1, (h / 4) - 1, "║")
  gpu.fill(w3x1 + 1, w3y2, w3x2 - 3, 1, "═")

  -- Window 4
  gpu.set(w4x1, w4y1, "╔")
  gpu.set(w4x2, w4y1, "╗")
  gpu.set(w4x1, w4y2, "╚")
  gpu.set(w4x2, w4y2, "╝")

  gpu.fill(w4x1 + 1, w4y1, w4x2 - w4x1 - 1, 1, "═")
  gpu.fill(w4x1, w4y1 + 1, 1, w4y2 - w4y1, "║")
  gpu.fill(w4x2, w4y1 + 1, 1, w4y2 - w4y1, "║")
  gpu.fill(w4x1 + 1, w4y2, w4x2 - w4x1 - 1, 1, "═")


  -- Set window names
  gpu.setForeground(0x00FF00)

  term.setCursor(w1x2 / 4, w1y1)
  print("Logger")

  term.setCursor(w1x2 + 1 + ((w2x2 - w2x1) / 4), w2y1)
  print("Terminal")

  term.setCursor(w3x2 / 4, w3y1)
  print("Console")

  term.setCursor(w3x2 + 1 + ((w4x2 - w4x1) / 4), w4y1)
  print("Status")
end


gpu.setForeground(0xFFFFFF)
--term.setCursor(0, w3y2 + 1)

return {
  screenWidth = w,
  screenHeight = h,
  drawWindows = drawWindows
}
