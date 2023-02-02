local function makenumberserializer(size)
  local formatprefix = "i"
  local format = formatprefix .. size
  return {
    pack = function(value)
      return string.pack(format, value)
    end,
    unpack = function(data)
      return string.unpack(format, data), size
    end,
  }
end

local numbers = {
  byte = makenumberserializer(1),
  short = makenumberserializer(2),
  int = makenumberserializer(4),
  long = makenumberserializer(8),
}

local function extendwithlength(baseserializer)
  local formatprefix = "I"
  local lengthsize = 4
  local format = formatprefix .. lengthsize
  return {
    pack = function(value)
      local serialized = baseserializer.pack(value)
      local length = string.pack(format, #serialized)
      return length .. serialized
    end,
    unpack = function(data)
      local length = string.unpack(format, data)
      data = data:sub(lengthsize + 1, lengthsize + length)
      local value = baseserializer.unpack(data)
      return value, lengthsize + length
    end,
  }
end

local numberswithlength = {
  byte = extendwithlength(numbers.byte),
  short = extendwithlength(numbers.short),
  int = extendwithlength(numbers.int),
  long = extendwithlength(numbers.long),
}

local strfields = {
  formatprefix = "c",
}
local rawstr = {
  pack = function(value)
    local length = #value
    return string.pack(strfields.formatprefix .. length, value)
  end,
  unpack = function(data)
    local length = #data
    return string.unpack(strfields.formatprefix .. length, data)
  end,
}
local str = extendwithlength(rawstr)

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
  return {
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
  return {
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
  return {
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
}
