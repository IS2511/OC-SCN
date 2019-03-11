--[[
  Secure Centralized Network (github.com/IS2511/OC-SCN)
  NODE part of the SCN system.

  Written by IS2511 (vk.com/IS2511)
  Idea by -Mappleaf (vk.com/inga_akuma)
]]--


local tty = require("tty") -- tty.clear()
local io = require("io")
local fs = require("filesystem")
local component = require("component")
local event = require("event")
local thread = require("thread")
local ser = require("serialization")
local m = component.modem
local d = component.data


local rootDirName = '/node'
local messageDirName = rootDirName..'/msg'
local vbufSize = 8192
local port = {
  service = 50011,
  ping = 50010,
  main = 50001
}



local hop = -1
local nodeFriends = {}

local messageHash = {} -- Message hash in received order (works like a stack)



function init()

  if fs.exists(rootDirName) then
    if ~fs.isDirectory(rootDirName) then
      fs.remove(rootDirName)
      fs.makeDirectory(rootDirName)
    end
  else
    fs.makeDirectory(rootDirName)
  end

  if fs.exists(messageDirName) then
    if ~fs.isDirectory(messageDirName) then
      fs.remove(messageDirName)
      fs.makeDirectory(messageDirName)
    end
  else
    fs.makeDirectory(messageDirName)
  end

  m.open(port.service)  -- Service port
  m.open(port.ping)     -- Ping port
  m.open(port.main)     -- Main port

end

function calculateHops ()
  local min = 0
  for k, v in pairs(nodeFriends) do
    if hop == -1 then
      hop = v.hops
    end
    if v.hops < min then
      min = v.hops
    end
  end
  hop = min + 1
end

-- function pingNeighbours ()
function scan ()
  calculateHops()
  for k, v in pairs(nodeFriends) do
    if ~v.ping then
      v.online = false
    end
    v.ping = false
  end
  m.setStrength(400) -- 400 is max
  m.broadcast(port.ping, ser.serialize("?"))
end

function packAES (data, key)
  local serializedData = ser.serialize(data)
  local hash = d.sha256(serializedData)
  local encryptedData = d.encrypt(serializedData, key, hash:sub(1, 4))
  return { data = encryptedData, hash = hash }
end

function unpackAES (payload, key)
  local serializedData = d.decrypt(payload.data, key, payload.hash:sub(1, 4))
  return { data = ser.unserialize(serializedData), hash = ( payload.hash == d.sha256(serializedData) ) }
end


function saveMessage (msg)
  local msgFile = io.open(messageDirName..msg.payload.hash..'.emsg', 'w')
  msgFile:write(ser.serialize(msg))
  messageHash[#messageHash + 1] = msg.payload.hash
end

function loadMessage ()
  if #messageHash == 0 then
    return nil
  end
  local hash = messageHash:remove(1)
  local msgFile = io.open(messageDirName..hash..'.emsg', 'rb')
  -- b:setvbuf(vbufSize)
  local msg = ser.unserialize(msgFile:read('*a'))
  masgFile:close()
  return msg
end

function deleteMessage (hash)
  fs.remove(messageDirName..hash..'.emsg')
  for k, v in pairs(messageHash) do
    if v == hash then
      messageHash:remove(k)
    end
  end
end

function doMessage (msg)

  msg.payload = ser.unserialize(msg.payload)


  if msg.port == port.service then       -- Service port

  elseif msg.port == port.ping then       -- Ping port

  -- PING --
  if msg.payload:sub(1, 1) == "?" then        -- Ping request
    io.write("Received ping request! Answering: ")
    io.write( "n"..tostring(hop).."\n" )   -- Ex.: [ {"n",4} ]
    m.setStrength(msg.distance + 1)
    m.send( msg.remoteAddress, msg.port, "n"..tostring(hop) )

  elseif msg.payload:sub(1, 1) == "n" then    -- Node's answer
    local hopsRecieved = tonumber(msg.payload:sub(2))
    io.write("Received answer: n"..hopsRecieved.."\n")
    nodeFriends[msg.remoteAddress] = {hops = hopsRecieved, ping = true, online = true}


  elseif msg.payload:sub(1, 1) == "c" then    -- Client's answer
    -- dafuq, no idea...

  end

  elseif msg.port == port.main then       -- Main port

  end

end


function main ()
  tty.clear()
  local msg = {}
  while true do
    msg = loadMessage()
    if msg ~= nil then
      doMessage(msg)
    end
  end
end

function modemHandle ()
  while true do
    local msg = {}
    --local _, localNetworkCard, remoteAddress, port, distance, payload = event.pull("modem_message")
    _, _, msg.remoteAddress, msg.port, msg.distance, msg.payload = event.pull("modem_message")
    --os.sleep(0)
    if msg.port == port.ping then
      doMessage(msg)
    else
      saveMessage(msg)
    end
  end

end

init()

local modemThread = thread.create(modemHandle)

main()


-- SIGNAL: name, arg, ...EVENT
--  EVENT: modem_message(receiverAddress: string, senderAddress: string, port: number, distance: number, ...)
