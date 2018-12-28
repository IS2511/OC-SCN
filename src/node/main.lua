--[[
  Secure Centrilized Network
  NODE part of the SCN system.

  Written by IS2511 (vk.com/IS2511)
  Idea by -Mappleaf (vk.com/inga_akuma)
]]--


local tty = require("tty") -- tty.clear()
local io = require("io")
local component = require("component")
local event = require("event")
local ser = require("serialization")
local m = component.modem
local d = component.data

local hop = -1
local hopsCount = 0
local hops = {}

function init()
  m.open(50010) -- Service port
  m.open(50001) -- Ping port
  m.open(50003) -- VIP port
  m.open(50002) -- Basic port

  m.setStrength(400) -- 400 is max
  m.broadcast(50001, ser.serialize("?"))

end

function calculateHops ()
  local min = 0
  for h in hops do
    if h < min then
      min = h end
  end
  hop = min + 1
end

function saveMessage (msg)

end

function loadMessage ()

end

function deleteMessage ()

end

function doMessage (msg)

  msg.payload = ser.unserialize(msg.payload)
  m.setStrength(msg.distance+1)

  if msg.port == 50010 then           -- Service port

  elseif msg.port == 50001 then       -- Ping port

    --PING
    if msg.payload:sub(1, 1) == "?" then        -- Ping request
      io.write("Received ping! Answering: ")
      io.write("n"..string.char(hop).." : "..hop)   -- Ex.: [ nFk : 8 ]
      m.send( msg.remoteAddress, msg.port, ser.serialize("n"..string.char(hop)) )

    elseif msg.payload:sub(1, 1) == "n" then    -- Node's answer
      local hopsRecieved = msg.payload:byte(2, 3)
      io.write("Received answer: n"..hopsRecieved.."\n")
      hops[hopsCount] = hopsRecieved
      hopsCount = hopsCount + 1

    elseif msg.payload:sub(1, 1) == "c" then    -- Client's answer
      -- dafuq, no idea...

    end

  elseif msg.port == 50003 then       -- VIP port

  elseif msg.port == 50002 then       -- Basic port

  end

end


function main ()
  while 1 do
    --tty.clear()
    local msg = {}
    --local _, localNetworkCard, remoteAddress, port, distance, payload = event.pull("modem_message")
    _, _, msg.remoteAddress, msg.port, msg.distance, msg.payload = event.pull("modem_message")
    --os.sleep(0)
    if msg.port == 50001 then
      doMessage(msg)
    else
      saveMessage(msg)
    end


  end
end

init()
main()


--  EVENT: modem_message(receiverAddress: string, senderAddress: string, port: number, distance: number, ...)
