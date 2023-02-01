local lu = require "luaunit"

local Packet = require "packet".Packet
local auth = require "packet".request.auth

Test_packet = {

  test_can_be_created = function()
    local packet = Packet()
    lu.assert_not_nil(packet)
  end,

  test_can_be_serialized = function()
    local type = -1
    local content = ""
    local packet = Packet(type, content)
    local expected = "\x11\x00\x00\x00\xff\xff\x00\x00\x00\x00"
    local actual = packet:pack()
    lu.assert_equals(actual, expected)
  end,

  test_can_be_deserialized = function()
    local data = "\x11\x00\x00\x00\xff\xff\x00\x00\x00\x00"
    local expected = {
      type = -1,
      content = "",
    }
    local actual = Packet:unpack(data)
    lu.assert_equals(actual.type, expected.type)
    lu.assert_equals(actual.content, expected.content)
  end,

  test_auth_request_packet_can_be_created = function()
    local login, password, deviceid = "login", "password", 0x12345678
    local packet = auth(login, password, deviceid)
    local expectedheader = "\x11\x00\x00\x00\x50\x00\x3c\x00\x00\x00"
    local actual = packet:pack()
    lu.assert_equals(actual:sub(1, #expectedheader), expectedheader)
    lu.assert_str_contains(actual, "login")
    lu.assert_str_contains(actual, "password")
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
