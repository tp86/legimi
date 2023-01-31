local class = require "class"

local function makenumberclass(size)
  local formatprefix = "i"
  local format = formatprefix .. size
  return class {
    format = format,
    pack = function(value)
      return string.pack(format, value)
    end,
    unpack = function(data)
      return string.unpack(format, data), size
    end,
    length = size,
  }
end

local numbers = {
  byte = makenumberclass(1),
  short = makenumberclass(2),
  int = makenumberclass(4),
  long = makenumberclass(8),
}

local lengthconf = {
  formatprefix = "I",
  size = 4,
}
local function extendwithlength(baseclass)
  local format = lengthconf.formatprefix .. lengthconf.size .. baseclass.format
  return class.extends(baseclass) {
    pack = function(value)
      return string.pack(format, baseclass.length, value)
    end,
    unpack = function(data)
      local _, value = string.unpack(format, data)
      return value, baseclass.length + lengthconf.size
    end,
  }
end

local numberswithlength = {
  byte = extendwithlength(numbers.byte),
  short = extendwithlength(numbers.short),
  int = extendwithlength(numbers.int),
  long = extendwithlength(numbers.long),
}

local strformatprefix = "c"
local lenstrformatprefix = lengthconf.formatprefix .. lengthconf.size .. strformatprefix
local str = class {
  pack = function(value)
    local length = #value
    return string.pack(lenstrformatprefix .. length, length, value)
  end,
  unpack = function(data)
    local length, next = string.unpack(lengthconf.formatprefix .. lengthconf.size, data)
    local value = string.unpack(strformatprefix .. length, data:sub(next))
    return value, lengthconf.size + length
  end,
}

local function newstate(data)
  return {
    data = data,
    length = 0,
  }
end

local function partialunpack(serializer, state)
  local value, length = serializer.unpack(state.data)
  state.data = state.data:sub(length + 1)
  state.length = state.length + length
  return value
end

local Sequence = function(serializers)
  return class {
    pack = function(values)
      local serialized = {}
      for i, serializer in ipairs(serializers) do
        local value = values[i]
        serialized[i] = serializer.pack(value)
      end
      return table.concat(serialized)
    end,
    unpack = function(data)
      local state = newstate(data)
      local values = {}
      for i, serializer in ipairs(serializers) do
        values[i] = partialunpack(serializer, state)
      end
      return values, state.length
    end,
  }
end

local Array = function(serializer)
  local countserializer = numbers.short
  return class {
    pack = function(values)
      local count = #values
      local serialized = {}
      table.insert(serialized, countserializer.pack(count))
      for _, value in ipairs(values) do
        table.insert(serialized, serializer.pack(value))
      end
      return table.concat(serialized)
    end,
    unpack = function(data)
      local state = newstate(data)
      local count = partialunpack(countserializer, state)
      local values = {}
      for i = 1, count do
        values[i] = partialunpack(serializer, state)
      end
      return values, state.length
    end,
  }
end

local Dictionary = function(serializers)
  local countserializer = numbers.short
  local keyserializer = numbers.short
  return class {
    pack = function(values)
      local count = 0
      local serialized = {}
      for key, value in pairs(values) do
        local serializer = serializers[key]
        if serializer then
          table.insert(serialized, keyserializer.pack(key))
          table.insert(serialized, serializer.pack(value))
          count = count + 1
        end
      end
      table.insert(serialized, 1, countserializer.pack(count))
      return table.concat(serialized)
    end,
    unpack = function(data)
      local state = newstate(data)
      local count = partialunpack(countserializer, state)
      local values = {}
      for _ = 1, count do
        local key = partialunpack(keyserializer, state)
        local serializer = serializers[key]
        if not serializer then
          serializer = str
        end
        local value = partialunpack(serializer, state)
        values[key] = value
      end
      return values, state.length
    end,
  }
end

local function makenewnumberclass(size)
  local formatprefix = "i"
  local format = formatprefix .. size
  return class {
    pack = function(value)
      return string.pack(format, value)
    end,
    unpack = function(data)
      return string.unpack(format, data), size
    end,
  }
end

local newnumbers = {
  short = makenewnumberclass(2)
}

local function newextendwithlength(baseclass)
  local formatprefix = "I"
  local lengthsize = 4
  local format = formatprefix .. lengthsize
  return class.extends(baseclass) {
    pack = function(value)
      local serialized = baseclass.pack(value)
      local length = string.pack(format, #serialized)
      return length .. serialized
    end,
    unpack = function(data)
      local length = string.unpack(format, data)
      data = data:sub(lengthsize + 1)
      local value = baseclass.unpack(data)
      return value, lengthsize + length
    end,
  }
end

local newlengthnumbers = {
  short = newextendwithlength(newnumbers.short)
}

return {
  RawByte = numbers.byte,
  RawShort = numbers.short,
  RawInt = numbers.int,
  RawLong = numbers.long,
  Byte = numberswithlength.byte,
  Short = numberswithlength.short,
  Int = numberswithlength.int,
  Long = numberswithlength.long,
  Str = str,
  Sequence = Sequence,
  Array = Array,
  Dictionary = Dictionary,

  NewShort = newnumbers.short,
  NewLenShort = newlengthnumbers.short,
}
