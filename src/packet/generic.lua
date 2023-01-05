local protocolversion = 17
local serializer = require "serializer"

local packetfmt = {
  "i4",
  "i2",
  serializer.str,
}

local function makepacket(type, content)
  local data = {
    protocolversion,
    type,
    content,
  }
  return serializer.pack(data, packetfmt)
end

local function readpacket(data)
  local deserialized = serializer.unpack(data, packetfmt)
  return {
    type = deserialized[2],
    content = deserialized[3],
  }
end

return {
  make = makepacket,
  read = readpacket,
}
