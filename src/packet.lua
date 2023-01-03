local authreqnew = {
  type = 80,
  user = 0,
  password = 1,
  deviceid = 2,
  appversion = 3,
}
local appversion = "1.5.0 Windows"

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
  authreq = makeauthreqnew,
}
