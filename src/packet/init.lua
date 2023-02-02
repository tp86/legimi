local ser = require "serializer"

local packetversion = require "config".packetversion

local packetserializer = ser.Sequence { ser.RawInt, ser.RawShort, ser.Str }
local Packet = {
  pack = function(type, content)
    return packetserializer.pack({ packetversion, type, content })
  end,
}

return {
  Packet = Packet,
}
