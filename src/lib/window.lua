local component = require("component")
local term = require("term")
gpu = component.gpu

local Menu = require("window-menu")

local Window = {
  wx1 = 0,
  wx2 = 0,
  wy1 = 0,
  wy2 = 0,
  width = 0,
  height = 0,
  maxSymbols = 0,
  maxLines = 0,
  name = "",
  type = ""
}

  -- Create a window
function Window.create(wx1, wx2, wy1, wy2, type, name)
  local obj = Window

  if ((not wx1) or (not wx2) or (not wy1) or (not wy2)) then
    error("Not enough arguments (maybe no size specified).")
  end

  obj.type = assert(type, "No window type specified.")
  if type == "text" then
    obj.content = ""
  elseif type == "list" then
    obj.list = {}
  elseif type == "menu" then
    local menu = {}
    obj.menu = Menu.create(menu)
  end

  if not name then
    obj.name = ""
  end

  if (wx1 >= wx2) or (wy1 >= wy2) then
    error("Window size is incorrect.")
  elseif ((wx1 < 3) or (wx2 < 3) or (wy1 < 3) or (wy2 < 3)) then
    error("Window size is smaller than minimal (Minimal size is: [3]).")
  end

  obj.wx1 = wx1
  obj.wx2 = wx2
  obj.wy1 = wy1
  obj.wy2 = wy2

  obj.width = wx2 - wx1
  obj.height = wy2 - wy1
  obj.maxSymbols = obj.width - 2
  obj.maxLines = obj.height - 2
  obj.name = name

  return obj
end

  -- Draw/redraw window
function Window:draw()
  gpu.set(self.wx1, self.wy1, "╔")
  gpu.set(self.wx2, self.wy1, "╗")
  gpu.set(self.wx1, self.wy2, "╚")
  gpu.set(self.wx2, self.wy2, "╝")

  gpu.fill(self.wx1 + 1, self.wy1, self.wx2 - self.wx1 - 1, 1, "═")
  gpu.fill(self.wx1 + 1, self.wy2, self.wx2 - self.wx1 - 1, 1, "═")
  gpu.fill(self.wx1, self.wy1 + 1, 1, self.wy2 - 1, "║")
  gpu.fill(self.wx2, self.wy1 + 1, 1, self.wy2 - 1, "║")

  term.setCursor(self.wx2 / 4, self.wy1)

  if (gpu.getDepth() == 1) then
    print(self.name)
  else
    if (gpu.getDepth() == 8) then
      gpu.setForeground(0x009950)
    elseif (gpu.getDepth() == 4) then
      gpu.setForeground(0x00FF00)
    end
    print(self.name)
    gpu.setForeground(0xFFFFFF)
  end


end


  -- Update window
function Window:update()

end




return Window
