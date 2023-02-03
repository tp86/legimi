local ser = require "serializer"
local errors = require(... .. ".errors")

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

local types = setmetatable({
  [16386] = Auth,
}, {
  __index = function(_, msgtype)
    local err = errors[msgtype]
    if err then
      error("Error: " .. err, 0)
    end
    error("Unknown/unsupported response type received: " .. msgtype)
  end,
})

return {
  types = types,
}
