local class = require "class"
local ser = require "serializer"
local Packet = require "packet".Packet

local appversion = require "config".appversion

local RequestBase = class {
  pack = function(cls, data)
    local content = cls.serializer.pack(data)
    return Packet.pack(cls.type, content)
  end,
}

local Auth = class.extends(RequestBase) {
  type = 80,
  serializer = ser.Dictionary {
    [0] = ser.Str, -- login
    ser.Str, -- password
    ser.Long, -- deviceid
    ser.Str -- appversion
  },
  pack = function(cls, login, password, deviceid)
    return RequestBase.pack(cls, { [0] = login, password, deviceid, appversion })
  end,
}

return {
  Auth = Auth,
}
