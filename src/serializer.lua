local lengthbytes = 4
local packdict, unpackdict
local formats = {
  str = "s4",
  count = "i2",
  int = "I" .. lengthbytes .. "i4",
  long = "I" .. lengthbytes .. "i8",
  dict = function(format)
    return {
      function(data) return packdict(data, format) end,
      function(data) return unpackdict(data, format) end,
    }
  end,
}

local function getlen(format)
  return tonumber(format:sub(#format))
end

local function withlen(format)
  return format:sub(1, 2) == "I4"
end

local pack

local function handlecompound(data, format, direction)
  if #format == 2 and type(format[1]) == "function" and type(format[2]) == "function" then
    return format[direction](data)
  else
    -- handle lua sequence
    local packed = ""
    for i, value in ipairs(data) do
      local packedvalue = pack(value, format[i])
      packed = packed .. packedvalue
    end
    return packed
  end
end

pack = function(value, format)
  if type(format) == "table" then
    return handlecompound(value, format, 1)
  else
    if not format then
      if type(value) == "string" then
        format = formats.str
      else
        format = formats.int
      end
    end
    local data = { value }
    if withlen(format) then
      table.insert(data, 1, getlen(format))
    end
    return string.pack(format, table.unpack(data))
  end
end

packdict = function(data, format)
  local count = 0
  local packed = ""
  for key, value in pairs(data) do
    local packedkey = pack(key, formats.count)
    local packedvalue = pack(value, format[key])
    packed = packed .. packedkey .. packedvalue
    count = count + 1
  end
  local packedcount = pack(count, formats.count)
  return packedcount .. packed
end

local function unpack(data, format)
  if type(format) == "table" then
    return handlecompound(data, format, 2)
  else
    local function strip(...)
      local function handlelength(values)
        if withlen(format) then
          table.remove(values, 1)
        end
      end

      local values = table.pack(...)
      handlelength(values)
      --table.remove(values)
      return table.unpack(values)
    end

    return strip(string.unpack(format, data))
  end
end

unpackdict = function(data, format)
  local totalread = 0
  local subdata = data
  local function advance(read)
    totalread = totalread + read
    subdata = subdata:sub(read)
  end

  local unpacked = {}
  local count, from = string.unpack(formats.count, subdata)
  advance(from)
  for _ = 1, count do
    ---@diagnostic disable-next-line: redefined-local
    local key, from = string.unpack(formats.count, subdata)
    advance(from)
    local value, read = unpack(subdata, format[key])
    advance(read)
    unpacked[key] = value
  end
  return unpacked, totalread
end

return {
  str = formats.str,
  int = formats.int,
  long = formats.long,
  count = formats.count,
  dict = formats.dict,
  pack = pack,
  unpack = unpack,
}
