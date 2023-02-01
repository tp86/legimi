require "test.serializersuite"
require "test.commsuite"

local runner = not ... or #arg > 0
if runner then
  local lu = require "luaunit"
  os.exit(lu.LuaUnit.run())
end
