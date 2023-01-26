---@diagnostic disable: lowercase-global
local lu = require "luaunit"

function test_basic()
  lu.assertTrue(true)
end

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
