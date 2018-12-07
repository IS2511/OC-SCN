local component = require("component")
local term = require("term")
local colors = require("colors")
local Window = require("window")
gpu = component.gpu

local path = (...)

local w, h = gpu.getResolution()  -- Gets screen getResolution


local windowLog = Window.create(2, w / 2 - 1, 1, h / 4 * 3 - 3, "text", "Logger")
local windowTerm = Window.create(w / 2 + 1, w - 2, 1, h / 4 * 3 - 3, "menu", "Node")
local windowCon = Window.create(2, w / 4 * 3 - 3, h / 4 * 3, h - 1, "text", "Console")
local windowStat = Window.create(w / 4 * 3 - 1, w - 2, h / 4 * 3, h - 1, "list", "Status")
