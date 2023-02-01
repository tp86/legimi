local lu = require "luaunit"

local requests = require "data.request"

Test_auth_request = {

  test_can_be_created = function()
    local AuthReq = requests.Auth
    local request = AuthReq()
    lu.assert_not_nil(request)
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
