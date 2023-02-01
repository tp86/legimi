local class = require "class"
local init = class.constructor
local ser = require "serializer"
local requests = require "data.request"

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

local types = {
  request = {
    auth = 80,
  }
}

local function auth(login, password, deviceid)
  local type = types.request.auth
  local content = requests.Auth(login, password, deviceid):pack()
  return Packet(type, content)
end

return {
  Packet = Packet,
  request = {
    auth = auth,
  }
}
