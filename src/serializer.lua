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
      return string.unpack(format, data)
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
      return value
    end,
    length = numberclass.length + length,
  }
end

local numberswithlength = {
  byte = extendwithlength(numbers.byte),
  short = extendwithlength(numbers.short),
  int = extendwithlength(numbers.int),
  long = extendwithlength(numbers.long),
}

local Sequence = function(serializers)
  local totallength = 0
  for _, serializer in ipairs(serializers) do
    totallength = totallength + serializer.length
  end
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
      local values = {}
      for i, serializer in ipairs(serializers) do
        values[i] = serializer.unpack(data)
        data = data:sub(serializer.length + 1)
      end
      return values
    end,
    length = totallength,
  }
end

local Array = function()
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
