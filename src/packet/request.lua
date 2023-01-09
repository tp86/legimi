local serializer = require "serializer"
local requests = {}
requests.auth = {
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
}
requests.auth.format = serializer.dict {
  [requests.auth.fields.user] = serializer.str,
  [requests.auth.fields.password] = serializer.str,
  [requests.auth.fields.deviceid] = serializer.lenlong,
  [requests.auth.fields.appversion] = serializer.str,
}
local packet = require "packet.generic"

local function makeauthreq(login, password, deviceid)
  local req = requests.auth
  local fields = req.fields
  local data = {
    [fields.user] = login,
    [fields.password] = password,
    [fields.deviceid] = deviceid,
    [fields.appversion] = req.constants.appversion,
  }
  local content = serializer.pack(data, req.format)
  return packet.make(req.type, content)
end

return {
  auth = makeauthreq,
}
