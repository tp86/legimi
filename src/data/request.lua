local ser = require "serializer"
local packet = require "packet"

local appversion = require "config".appversion

local function packrequest(request, data)
  local content = request.serializer.pack(data)
  return packet.serializer.pack({ packet.version, request.type, content })
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

local Activate = {
  type = 66,
  serializer = ser.Sequence {
    ser.RawLong, -- empty device id
    ser.ShortStr, -- login
    ser.ShortStr, -- password
    ser.ShortStr, -- serial number
    ser.ShortStr, -- locale
  },
  pack = function(self, login, password, serialno)
    local deviceid = 0
    serialno = "Kindle||Kindle||" .. serialno .. "||Kindle"
    local locale = ""
    return packrequest(self, { deviceid, login, password, serialno, locale })
  end,
}

return {
  Auth = Auth,
  Activate = Activate,
}
