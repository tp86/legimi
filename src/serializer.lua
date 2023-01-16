local pack, unpack

local function packseq(data, format)
  local packed = ""
  for i, value in ipairs(data) do
    local packedvalue = pack(value, format[i])
    packed = packed .. packedvalue
  end
  return packed
end

local function unpackseq(data, format)
  local totalread = 0
  local subdata = data
  local function advance(read)
    totalread = totalread + read
    subdata = subdata:sub(read + 1)
  end

  local unpacked = {}
  for _, fmt in ipairs(format) do
    local value, read = unpack(subdata, fmt)
    advance(read)
    table.insert(unpacked, value)
  end
  return unpacked, totalread
end

local formats = {
  key = "i2",
  count = "i2",
}

local function packdict(data, format)
  local count = 0
  local packed = ""
  for key, value in pairs(data) do
    local packedkey = pack(key, formats.key)
    local packedvalue = pack(value, format[key])
    packed = packed .. packedkey .. packedvalue
    count = count + 1
  end
  local packedcount = pack(count, formats.count)
  return packedcount .. packed
end

local function unpackdict(data, format)
  local totalread = 0
  local subdata = data
  local function advance(read)
    totalread = totalread + read
    subdata = subdata:sub(read + 1)
  end

  local unpacked = {}
  local count, from = string.unpack(formats.count, subdata)
  advance(from - 1)
  for _ = 1, count do
    ---@diagnostic disable-next-line: redefined-local
    local key, from = string.unpack(formats.count, subdata)
    advance(from - 1)
    local value, read = unpack(subdata, format[key])
    advance(read)
    unpacked[key] = value
  end
  return unpacked, totalread
end

local function packarray(data, format)
  local count = 0
  local packed = ""
  for _, value in ipairs(data) do
    local packedvalue = pack(value, format)
    packed = packed .. packedvalue
    count = count + 1
  end
  local packedcount = pack(count, formats.count)
  return packedcount .. packed
end

local function unpackarray(data, format)
  local totalread = 0
  local subdata = data
  local function advance(read)
    totalread = totalread + read
    subdata = subdata:sub(read + 1)

  end

  local unpacked = {}
  local count, from = string.unpack(formats.count, subdata)
  advance(from - 1)
  for _ = 1, count do
    local value, read = unpack(subdata, format)
    advance(read)
    unpacked[#unpacked + 1] = value
  end
  return unpacked, totalread
end

local directions = {
  pack = 1,
  unpack = 2,
}

local sequence = {
  [directions.pack] = packseq,
  [directions.unpack] = unpackseq,
}

formats.str = "s4"
formats.count = "i2"
formats.int = "i4"
formats.long = "i8"
formats.short = "i2"
formats.byte = "i1"

local lengthbytes = 4
local lengthformat = "I" .. lengthbytes
local function getlen(format)
  return tonumber(format:sub(#lengthformat + 2))
end

local function withlen(format)
  return format:sub(1, 2) == lengthformat
end

formats.lenint = lengthformat .. formats.int
formats.lenlong = lengthformat .. formats.long
formats.lenshort = lengthformat .. formats.short
formats.lenbyte = lengthformat .. formats.byte
formats.dict = function(format)
  return {
    [directions.pack] = function(data) return packdict(data, format) end,
    [directions.unpack] = function(data) return unpackdict(data, format) end,
  }
end
formats.array = function(format)
  return {
    [directions.pack] = function(data) return packarray(data, format) end,
    [directions.unpack] = function(data) return unpackarray(data, format) end,
  }
end

local function handlecompound(data, format, direction)
  if #format == 2 and type(format[1]) == "function" and type(format[2]) == "function" then
    return format[direction](data)
  else
    return sequence[direction](data, format)
  end
end

pack = function(value, format)
  if type(format) == "table" then
    return handlecompound(value, format, directions.pack)
  else
    if not format then
      if type(value) == "string" then
        format = formats.str
      else
        format = formats.lenint
      end
    end
    local data = { value }
    if withlen(format) then
      table.insert(data, 1, getlen(format))
    end
    return string.pack(format, table.unpack(data))
  end
end

unpack = function(data, format)
  if type(format) == "table" then
    return handlecompound(data, format, directions.unpack)
  else
    local function strip(...)
      local values = table.pack(...)
      if withlen(format) then
        table.remove(values, 1)
      end
      local read = table.remove(values) - 1
      table.insert(values, read)
      return table.unpack(values)
    end

    return strip(string.unpack(format, data))
  end
end

return {
  str = formats.str,
  int = formats.int,
  lenint = formats.lenint,
  lenlong = formats.lenlong,
  lenshort = formats.lenshort,
  lenbyte = formats.lenbyte,
  count = formats.count,
  key = formats.key,
  dict = formats.dict,
  array = formats.array,
  pack = pack,
  unpack = unpack,
}
