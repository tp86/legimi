local lu = require "luaunit"

local flow = require "flow"

Test_flow = {

  test_get_session_id = function()
    local sessionid = flow.getsessionid()
    lu.assert_equals(#sessionid, 32)
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
