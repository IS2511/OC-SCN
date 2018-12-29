
local deepcopy = require("deepcopy").deepcopy

local List = {
  first = 1,
  last = 0,
  list = {}
}

function List.new ()
  return deepcopy(List)
end

function List:get (index)
  return self.list[index]
end

function List:set (index, value)
  if not ( self.last >= index and index >= self.first ) then error("Index out of bounds") end
  self.list[index] = value
end

function List:insert (index, value)
  self.list:insert(index, value)
end

function List:clone ()
  return deepcopy(self)
end

function List:pushRight (value)
  local last = self.last + 1
  self.last = last
  self.list[last] = value
end

function List:popRight ()
  local last = self.last
  if self.first > last then error("List is empty") end
  local value = self.list[last]
  self.list[last] = nil         -- To allow garbage collection
  self.list.last = last - 1
  return value
end
