local protocolversion = 17
local authreqnew = {
  type = 80,
  user = 0,
  password = 1,
  deviceid = 2,
  appversion = 3,
}
local appversion = "1.5.0 Windows"

local function number(n, bytes, unsigned)
  bytes = bytes or 4
  local nformat = unsigned and "I" or "i"
  local packfmt = "<" .. nformat .. bytes
  return string.pack(packfmt, n)
end

local function length(n)
  return number(n, 4, true)
end

local function dictionary(fields)
  local serialized = {}
  local count = 0
  for n, content in pairs(fields) do
    table.insert(serialized, number(n, 2))
    table.insert(serialized, length(#content))
    table.insert(serialized, content)
    count = count + 1
  end
  table.insert(serialized, 1, number(count, 2))
  return table.concat(serialized)
end

local function makepacket(type, data)
  local packet = {}
  table.insert(packet, number(protocolversion))
  table.insert(packet, number(type, 2))
  table.insert(packet, length(#data))
  table.insert(packet, data)
  return table.concat(packet)
end

local function makeauthreqnew(login, password, deviceid)
  return makepacket(authreqnew.type,
    dictionary {
      [authreqnew.user] = login,
      [authreqnew.password] = password,
      [authreqnew.deviceid] = number(deviceid, 8),
      [authreqnew.appversion] = appversion,
      --[4] = number(0),
      --[5] = number(0, 8),
    })
end

local function printbs(bytes)
  for b = 1, #bytes, 16 do
    local chunk = table.pack(bytes:byte(b, b + 15))
    local len = #chunk
    print(string.format(string.rep("%02x ", len), table.unpack(chunk)))
  end
end

return {
  authreqnew = makeauthreqnew,
  print = printbs,
}
