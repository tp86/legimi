---@diagnostic disable: undefined-global
describe("packet", function()
  local emptypacket = '\x11\x00\x00\x00\xff\xff\x00\x00\x00\x00'
  describe("generic", function()
    local packet = require "packet.generic"
    it("can be serialized", function()
      local type, content = -1, ""
      local serialized = packet.make(type, content)
      local expected = emptypacket
      assert.equals(expected, serialized)
    end)
    it("can be deserialized", function()
      local serialized = emptypacket
      local p = packet.read(serialized)
      local expected = {
        type = -1,
        content = "",
      }
      for k, v in pairs(expected) do
        assert.equals(v, p[k], k .. " key mismatch")
      end
    end)
  end)
  describe("request", function()
    describe("auth", function()
      it("can be serialized", function()
        local requests = require "packet.request"
        local login, pass = "login", "password"
        local serialized = requests.auth(login, pass, 0)
        local expectedheader = '\x11\x00\x00\x00\x50\x00'
        assert.equals(expectedheader, serialized:sub(1, #expectedheader))
        assert.is_truthy(string.find(serialized, login))
        assert.is_truthy(string.find(serialized, pass))
      end)
    end)
  end)
end)
