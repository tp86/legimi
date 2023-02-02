local ser = require "serializer"

local Auth = {
  serializer = ser.Dictionary {
    [7] = ser.Str, -- sessionid
  },
  unpack = function(self, data)
    local unpacked = self.serializer.unpack(data)
    return {
      sessionid = unpacked[7],
    }
  end,
}

local types = {
  [16386] = Auth,
}

return {
  types = types,
}
