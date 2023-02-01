local class = require "class"
local init = class.constructor
local ser = require "serializer"

local packetversion = 17

local Packet = class {
  serializer = ser.Sequence { ser.RawInt, ser.RawShort, ser.Str },
  [init] = function(self, type, content)
    self.type = type
    self.content = content
  end,
  pack = function(self)
    return self.serializer.pack({ packetversion, self.type, self.content })
  end,
  unpack = function(cls, data)
    local unpacked = cls.serializer.unpack(data)
    return cls(unpacked[2], unpacked[3])
  end,
}

return {
  Packet = Packet,
}
