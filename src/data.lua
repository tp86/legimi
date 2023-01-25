local class = require "class"
local init = class.constructor

local Number = class {
  formatprefix = "i",
  [init] = function(self, value)
    self.value = value
    self.format = self.formatprefix .. self.length
  end,
  set = function(self, value)
    self.value = value
  end,
  pack = function(self)
    return string.pack(self.format, self.value)
  end,
  unpack = function(self, data)
    self.value = string.unpack(self.format, data)
  end,
}

local function makenumberclass(length)
  local function numberinit(self, value)
    class.parent(self)(value)
  end

  return class.extends(Number) {
    length = length,
    [init] = numberinit,
  }
end

local numbers = {
  byte = makenumberclass(1),
  short = makenumberclass(2),
  int = makenumberclass(4),
  long = makenumberclass(8),
}

local Length = class {
  [init] = function(self)
    self.format = "I4" .. self.format
  end,
  pack = function(self)
    return string.pack(self.format, self.length, self.value)
  end,
  unpack = function(self, data)
    local _, value = string.unpack(self.format, data)
    self.value = value
  end,
}

local function extendwithlength(numberclass)
  local function initfn(self, value)
    class.parent(self, numberclass)(value)
    class.parent(self, Length)()
  end

  return class.extends(Length, numberclass) {
    [init] = initfn,
  }
end

local numberswithlength = {
  byte = extendwithlength(numbers.byte),
  short = extendwithlength(numbers.short),
  int = extendwithlength(numbers.int),
  long = extendwithlength(numbers.long),
}

--[[
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
--]]

local Sequence = function(types)
  local function set(self, ...)
    local values = table.pack(...)
    for i = 1, values.n do
      if not self.values then self.values = {} end
      local value = values[i]
      self.values[i] = value
    end
  end

  local function seqinit(self, ...)
    set(self, ...)
  end

  local function pack(self)
    local serialized = {}
    for i, datatype in ipairs(self.types) do
      local value = self.values[i]
      local typedvalue
      if type(value) == "table" then
        typedvalue = datatype(table.unpack(value))
      else
        typedvalue = datatype(value)
      end
      serialized[i] = typedvalue:pack()
    end
    return table.concat(serialized)
  end

  return class {
    types = types,
    [init] = seqinit,
    set = set,
    pack = pack,
  }
end

return {
  Byte = numbers.byte,
  Short = numbers.short,
  Int = numbers.int,
  Long = numbers.long,
  LenByte = numberswithlength.byte,
  LenShort = numberswithlength.short,
  LenInt = numberswithlength.int,
  LenLong = numberswithlength.long,
  Sequence = Sequence,
}
