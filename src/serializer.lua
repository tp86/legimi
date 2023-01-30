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

local function extendwithlength(numberclass)
  local formatprefix = "I"
  local length = 4
  local format = formatprefix .. length .. numberclass.format
  return class.extends(numberclass) {
    pack = function(value)
      return string.pack(format, numberclass.length, value)
    end,
    unpack = function(data)
      local _, value = string.unpack(format, data)
      return value, numberclass.length + length
    end,
  }
end

local numberswithlength = {
  byte = extendwithlength(numbers.byte),
  short = extendwithlength(numbers.short),
  int = extendwithlength(numbers.int),
  long = extendwithlength(numbers.long),
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
  local array
  array = class {
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
  return array
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
