local class = require "class"
local init = class.constructor

local function passthroughinit(self, ...)
  class.parent(self)(...)
end

local Number = class {
  formatprefix = "i",
  [init] = function(self, value)
    self.value = value
    self.format = self.formatprefix .. self.size
  end,
  get = function(self)
    return self.value
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

local function makenumberclass(size)
  return class.extends(Number) {
    size = size,
    [init] = passthroughinit,
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
    return string.pack(self.format, self.size, self:get())
  end,
  unpack = function(self, data)
    local _, value = string.unpack(self.format, data)
    self:set(value)
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

local Multivalued = class {
  [init] = function(self, values)
    self:set(values)
  end,
  set = function(self, values)
    for i, value in pairs(values or {}) do
      if not self.values then self.values = {} end
      self.values[i] = value
    end
  end,
  get = function(self)
    return self.values
  end,
}

local GenericSequence = class.extends(Multivalued) {
  [init] = passthroughinit,
  pack = function(self)
    local serialized = {}
    for i, datatype in ipairs(self.types) do
      local value = self.values[i]
      serialized[i] = datatype(value):pack()
    end
    return table.concat(serialized)
  end,
  unpack = function(self, data)
    local values = {}
    for i, datatype in ipairs(self.types) do
      local dataobject = datatype()
      dataobject:unpack(data)
      values[i] = dataobject:get()
      data = data:sub(dataobject:length() + 1)
    end
    self.values = values
  end,
  length = function(self)
    local totallength = 0
    for _, datatype in ipairs(self.types) do
      totallength = totallength + datatype():length()
    end
    return totallength
  end,
}

local Sequence = function(types)
  return class.extends(GenericSequence) {
    types = types,
    [init] = passthroughinit,
  }
end

local Array = function()
  return class.extends(Multivalued) {
    [init] = passthroughinit,
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
  Array = Array,
}
