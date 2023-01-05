local pack

local function packseq(data, format)
  local packed = ""
  for i, value in ipairs(data) do
    local packedvalue = pack(value, format[i])
    packed = packed .. packedvalue
  end
  return packed
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

local unpack

local function unpackdict(data, format)
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

local directions = {
  pack = 1,
  unpack = 2,
}

local sequence = {
  [directions.pack] = packseq,
  --[directions.unpack] = unpackseq,
}

formats.str = "s4"
formats.count = "i2"

local lengthbytes = 4
local lengthformat = "I" .. lengthbytes
local function getlen(format)
  return tonumber(format:sub(#lengthformat + 2))
end
local function withlen(format)
  return format:sub(1, 2) == lengthformat
end

formats.int = lengthformat .. "i4"
formats.long = lengthformat .. "i8"
formats.dict = function(format)
  return {
    [directions.pack] = function(data) return packdict(data, format) end,
    [directions.unpack] = function(data) return unpackdict(data, format) end,
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

unpack = function(data, format)
  if type(format) == "table" then
    return handlecompound(data, format, directions.unpack)
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

return {
  str = formats.str,
  int = formats.int,
  long = formats.long,
  count = formats.count,
  dict = formats.dict,
  pack = pack,
  unpack = unpack,
}
