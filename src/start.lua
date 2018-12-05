local component = require("component")
local os = require("os")
gpu = component.gpu



local w, h = gpu.getResolution();

if h < 50 then
  print("Your screen width (", w, ") is lower than required. Minimum resolution is: 100x50");
elseif w < 100 then
  print("Your screen height (", h, ") is lower than required. Minimum resolution is: 100x50");
else
  os.execute("lib/gui.lua");
end;
