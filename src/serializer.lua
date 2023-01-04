local function makeformatter(fmt, length)
  return function(value)
    local format = { fmt, length }
    local data = { value }
    return format, data, length
  end
end

local function withlen(formatter)
  return function(value)
    local format, data, length = formatter(value)
    table.insert(format, #format - 1, "I4")
    table.insert(data, #data, length)
    return format, data, length + 4
  end
end

local function numberformatter(length)
  return makeformatter("i", length)
end

local function str(value)
  return makeformatter("c", #value)(value)
end

local function lenstr(value, unpacking)
  local format, data, length = withlen(str)(value)
  if unpacking then
    table.insert(format, table.remove(format) - 4)
    table.remove(data, 1)
    length = length - 4
  end
  return format, data, length
end

local formatters = {}
formatters.short = numberformatter(2)
formatters.int = numberformatter(4)
formatters.long = numberformatter(8)
formatters.str = str
formatters.lenint = withlen(formatters.int)
formatters.lenlong = withlen(formatters.long)
formatters.lenstr = lenstr

local function pack(value, format)
  format = format or (type(value) == "string" and "str" or "int")
  local formatter = formatters[format]
  local fmt, data = formatter(value)
  table.insert(fmt, 1, "<")
  return string.pack(table.concat(fmt), table.unpack(data))
end

local function unpack(value, format)
  format = format or "int"
  local formatter = formatters[format]
  local fmt = formatter(value, true)
  table.insert(fmt, 1, "<")
  local unpacked = table.pack(string.unpack(table.concat(fmt), value))
  table.remove(unpacked, unpacked.n)
  return table.unpack(unpacked)
end

local function dict(data, format)
  local function extendtbl(tbl, other)
    for _, value in ipairs(other) do
      table.insert(tbl, value)
    end
  end

  local function extend2tbl(tbl1, tbl2, other1, other2)
    extendtbl(tbl1, other1)
    extendtbl(tbl2, other2)
  end

  local count = 0
  local fmt, dt = {}, {}
  for key, value in pairs(data) do
    local formatter = formatters[format[key]]
    extend2tbl(fmt, dt, formatter(value))
    count = count + 1
  end
  extend2tbl(fmt, dt, formatters.short(count))
  table.insert(fmt, 1, "<")
  return string.pack(table.concat(fmt), table.unpack(dt))
end

return {
  int = "int",
  lenint = "lenint",
  short = "short",
  long = "long",
  lenlong = "lenlong",
  str = "str",
  lenstr = "lenstr",
  pack = pack,
  unpack = unpack,
  dict = dict,
}

