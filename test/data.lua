local lu = require "luaunit"

local requests = require "data.request"

local AuthReq = requests.Auth

Test_auth_request = {

  test_can_be_serialized = function()
    local login, password, deviceid = "login", "password", 0x12345678
    local expected = {
      header = "\x11\x00\x00\x00\x50\x00\x3c\x00\x00\x00",
      content = {
        count = "\x04\x00",
        parts = {
          "\x00\x00\x05\x00\x00\x00login",
          "\x01\x00\x08\x00\x00\x00password",
          "\x02\x00\x08\x00\x00\x00\x78\x56\x34\x12",
          "\x03\x00\x0d\x00\x00\x001.5.0 Windows",
        }
      }
    }
    local actual = AuthReq:pack(login, password, deviceid)
    local from, to = 1, #expected.header
    lu.assert_equals(actual:sub(from, to), expected.header)
    from = to + 1
    to = from + #expected.content.count - 1
    lu.assert_equals(actual:sub(from, to), expected.content.count)
    from = to + 1
    for _, part in ipairs(expected.content.parts) do
      lu.assert_str_contains(actual:sub(from), part)
    end
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
