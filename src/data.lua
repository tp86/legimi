local class = require "class"
local init = class.constructor

local Number = class {
  formatprefix = "i",
  [init] = function(self, value)
    self.value = value
    self.format = self.formatprefix .. self.size
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
  length = function(self)
    return self.size
  end,
}

local function numberinit(self, value)
  class.parent(self)(value)
end

local function makenumberclass(size)
  return class.extends(Number) {
    size = size,
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
  formatprefix = "I",
  lengthsize = 4,
  [init] = function(self)
    self.format = self.formatprefix .. self.lengthsize .. self.format
  end,
  pack = function(self)
    return string.pack(self.format, self.size, self.value)
  end,
  unpack = function(self, data)
    local _, value = string.unpack(self.format, data)
    self.value = value
  end,
  length = function(self)
    return self.size + self.lengthsize
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

local Sequence
do
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

  local function unpack(self, data)
    local values = {}
    for i, datatype in ipairs(self.types) do
      local dataobject = datatype()
      dataobject:unpack(data)
      values[i] = dataobject.value
      data = data:sub(dataobject:length() + 1)
    end
    self.values = values
  end

  Sequence = function(types)
    return class {
      types = types,
      [init] = seqinit,
      set = set,
      pack = pack,
      unpack = unpack,
    }
  end
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
