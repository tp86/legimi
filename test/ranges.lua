local lu = require "luaunit"

local ranges = require "util".ranges

Test_chunks = function()
  local boundaries = {}
  for from, to in ranges(10, 10) do
    table.insert(boundaries, { from, to })
  end
  lu.assert_equals(boundaries, { { 0, 9 }, { 10, 10 } })
end

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
