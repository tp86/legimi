local requests = {
  auth = {
    type = 80,
    fields = {
      user = 0,
      password = 1,
      deviceid = 2,
      appversion = 3,
    },
    constants = {
      appversion = "1.5.0 Windows",
    },
  },
}
local packet = require "packet.generic"
local serializer = require "serializer"

local function makeauthreq(login, password, deviceid)
  local req = requests.auth
  local fields = req.fields
  local data = {
    [fields.user] = login,
    [fields.password] = password,
    [fields.deviceid] = deviceid,
    [fields.appversion] = req.constants.appversion,
  }
  local fmt = {
    [fields.user] = serializer.str,
    [fields.password] = serializer.str,
    [fields.deviceid] = serializer.long,
    [fields.appversion] = serializer.str,
  }
  local content = serializer.pack(serializer.dictionary(fmt, data))
  return packet.make(req.type, content)
end

return {
  auth = makeauthreq,
}
