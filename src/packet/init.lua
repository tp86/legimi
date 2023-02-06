local ser = require "serializer"
local response = require "data.response".types

local version = require "config".packetversion

local serializer = ser.Sequence { ser.RawInt, ser.RawShort, ser.Str }

local unpack = function(data)
  local parts = serializer.unpack(data)
  local type, content = parts[2], parts[3]
  return response[type]:unpack(content)
end

return {
  version = version,
  serializer = serializer,
  unpack = unpack,
}
