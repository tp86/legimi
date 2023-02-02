local ser = require "serializer"
local Packet = require "packet".Packet

local appversion = require "config".appversion

local function packrequest(request, data)
  local content = request.serializer.pack(data)
  return Packet.pack(request.type, content)
end

local Auth = {
  type = 80,
  serializer = ser.Dictionary {
    [0] = ser.Str, -- login
    ser.Str, -- password
    ser.Long, -- deviceid
    ser.Str -- appversion
  },
  pack = function(self, login, password, deviceid)
    return packrequest(self, { [0] = login, password, deviceid, appversion })
  end,
}

return {
  Auth = Auth,
}
