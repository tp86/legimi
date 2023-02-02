local class = require "class"
local ser = require "serializer"

local packetversion = require "config".packetversion

local packetbase = ser.Sequence { ser.RawInt, ser.RawShort, ser.Str }
local Packet = class.extends(packetbase) {
  pack = function(type, content)
    return packetbase.pack({ packetversion, type, content })
  end,
}

return {
  Packet = Packet,
}
