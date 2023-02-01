local lu = require "luaunit"

local requests = require "data.request"

local AuthReq = requests.Auth

Test_auth_request = {

  test_can_be_created = function()
    local request = AuthReq()
    lu.assert_not_nil(request)
  end,

  test_can_be_serialized = function()
    local login, password, deviceid = "login", "password", 0x12345678
    local request = AuthReq(login, password, deviceid)
    local expectedparts = {
      "\x00\x00\x05\x00\x00\x00login",
      "\x01\x00\x08\x00\x00\x00password",
      "\x02\x00\x08\x00\x00\x00\x78\x56\x34\x12",
      "\x03\x00\x0d\x00\x00\x001.5.0 Windows",
    }
    local actual = request:pack()
    lu.assert_equals(actual:sub(1, 2), "\x04\x00")
    for _, part in ipairs(expectedparts) do
      lu.assert_str_contains(actual, part)
    end
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
