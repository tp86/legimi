local lu = require "luaunit"

local Packet = require "packet".Packet

Test_packet = {

  test_can_be_created = function()
    local packet = Packet()
    lu.assert_not_nil(packet)
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
