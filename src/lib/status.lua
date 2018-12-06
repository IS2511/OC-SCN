local component = require("component")
local gui = require("gui")
gpu = component.gpu

local path = (...)

local sWindowHeight = ((gui.screenHeight - 1) - (gui.screenHeight / 4 * 3))
local sWindowWidth = ((gui.screenWidth - 2) - (gui.screenWidth / 4 * 3 - 1))

print(sWindowWidth..", "..sWindowHeight)