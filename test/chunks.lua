local lu = require "luaunit"

local function chunks(total, size)
  size = size or 81920
  local next = 0
  return function()
    if next > total then
      return nil
    end
    local from, to = next, math.min(next + size - 1, total)
    next = to + 1
    return from, to
  end, nil, next
end

Test_chunks = function()
  local boundaries = {}
  for from, to in chunks(81920) do
    table.insert(boundaries, { from, to })
  end
  lu.assert_equals(boundaries, { { 0, 9 }, { 10, 10 } })
end

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
