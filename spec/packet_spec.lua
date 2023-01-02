---@diagnostic disable: undefined-global
describe("packet", function()
  it("can be serialized", function()
    local packet = require "packet"
    local serialized = packet.authreqnew("", "", 0)
    assert.equals(17, serialized:byte(1, 1))
  end)
end)
