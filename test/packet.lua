local lu = require "luaunit"

local packet = require "packet"

Test_packet = {

  test_can_serialize_data = function()
    local type = -1
    local content = ""
    local expected = "\x11\x00\x00\x00\xff\xff\x00\x00\x00\x00"
    local actual = packet.pack(type, content)
    lu.assert_equals(actual, expected)
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
