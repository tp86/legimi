local classmt = {
  __call = function(cls, value)
    local obj = {
      value = value,
    }
    setmetatable(obj, cls)
    return obj
  end,
}

local Byte = {
  valuelength = 1,
  getformat = function(self)
    local format = "i" .. self.valuelength
    if self.length then
      format = "I" .. self.length .. format
    end
    return format
  end,
  makedata = function(self)
    local data = { self.value }
    if self.length then
      table.insert(data, 1, self.valuelength)
    end
    return data
  end,
  pack = function(self)
    return string.pack(self:getformat(), table.unpack(self:makedata()))
  end,
  unpack = function(self, data)
    local values = table.pack(string.unpack(self:getformat(), data))
    if self.length then
      table.remove(values, 1)
    end
    self.value = values[1]
    return self, data:sub(values[2])
  end,
  withlength = function(self, length)
    self.length = length or 4
    return self
  end,
}
Byte.__index = Byte
setmetatable(Byte, classmt)

local Sequence = {}
Sequence.__index = Sequence
setmetatable(Sequence, classmt)

Sequence.pack = function(self)
  local packed = {}
  for _, value in ipairs(self.value) do
    table.insert(packed, value:pack())
  end
  return table.concat(packed)
end
Sequence.withformat = function(format)
  return {
    unpack = function(data)
      local values = {}
      for _, fmt in ipairs(format) do
        local unpacked = table.pack(fmt.unpack(data))
        local value = unpacked[1]
        data = unpacked[2]
        table.insert(values, value)
      end
      return Sequence(values), data
    end
  }
end

return {
  byte = Byte,
  sequence = Sequence,
}

