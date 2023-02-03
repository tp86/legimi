local ser = require "serializer"
local response = require "data.response".types

local packetversion = require "config".packetversion

local packetserializer = ser.Sequence { ser.RawInt, ser.RawShort, ser.Str }

local pack = function(type, content)
  return packetserializer.pack({ packetversion, type, content })
end

local unpack = function(data)
  local parts = packetserializer.unpack(data)
  local type, content = parts[2], parts[3]
  return response[type]:unpack(content)
end

return {
  pack = pack,
  unpack = unpack,
}
