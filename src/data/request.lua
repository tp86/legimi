local class = require "class"
local init = class.constructor
local ser = require "serializer"

local appversion = "1.5.0 Windows"

local fields = {
  auth = {
    login = 0,
    password = 1,
    deviceid = 2,
    appversion = 3,
  }
}
local Auth = class {
  serializer = ser.Dictionary {
    [fields.auth.login] = ser.Str,
    [fields.auth.password] = ser.Str,
    [fields.auth.deviceid] = ser.Long,
    [fields.auth.appversion] = ser.Str,
  },
  [init] = function(self, login, password, deviceid)
    self.login = login
    self.password = password
    self.deviceid = deviceid
  end,
  pack = function(self)
    return self.serializer.pack {
      [fields.auth.login] = self.login,
      [fields.auth.password] = self.password,
      [fields.auth.deviceid] = self.deviceid,
      [fields.auth.appversion] = appversion,
    }
  end,
}

return {
  Auth = Auth,
}
