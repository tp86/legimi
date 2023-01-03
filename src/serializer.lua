local formats = {
  short = "i2",
  len = "I4",
  str = "c",
}
local function buildfmt(format)
  local fmt = { "<" }
  for _, f in ipairs(format) do
    table.insert(fmt, f)
  end
  return table.concat(fmt)
end

local function serialize(data, format)
  local fmt = buildfmt(format)
  return string.pack(fmt, table.unpack(data))
end

local function deserialize(data, format)
  local fmt = buildfmt(format)
  local deserialized = table.pack(string.unpack(fmt, data))
  local nextpos = table.remove(deserialized)
  return deserialized, data:sub(nextpos)
end

-- TODO refactor
local function dictionary(format, data)
  local function datalen(value, fmt)
    if fmt == formats.str then
      local l = #value
      return l, fmt .. l
    else
      return tonumber(fmt:sub(2)), fmt
    end
  end
  local fmt, d = {}, {}
  local count = 0
  for k, f in pairs(format) do
    local v = data[k]
    table.insert(fmt, formats.short)
    table.insert(d, k)
    table.insert(fmt, formats.len)
    local len, lenfmt = datalen(v, f)
    table.insert(d, len)
    table.insert(fmt, lenfmt)
    table.insert(d, v)
    count = count + 1
  end
  table.insert(fmt, 1, formats.short)
  table.insert(d, 1, count)
  return d, fmt
end

return {
  int = "i4",
  short = formats.short,
  long = "i8",
  len = formats.len,
  lenstr = "s4",
  str = formats.str,
  pack = serialize,
  unpack = deserialize,
  dictionary = dictionary,
}

