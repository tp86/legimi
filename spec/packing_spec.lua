---@diagnostic disable: undefined-global

local Data = require "data"
describe("packing serializes", function()

  describe("byte", function()

    local Byte = Data.byte

    it("without length", function()
      local byte = Byte(3)
      local expected = "\x03"
      local actual = byte:pack()
      assert.equal(expected, actual)
    end)

    describe("with length", function()

      it("with default size", function()
        local byte = Byte(4)
        local expected = "\x01\x00\x00\x00\x04"
        byte:withlength()
        local actual = byte:pack()
        assert.equal(expected, actual)
      end)

      it("with custom size", function()
        local byte = Byte(5)
        local expected = "\x01\x00\x05"
        byte:withlength(2)
        local actual = byte:pack()
        assert.equal(expected, actual)
      end)
    end)
  end)

  it("sequence", function()
    local Seq = Data.sequence
    local Byte = Data.byte
    local seq = Seq({ Byte(6):withlength(3), Byte(7) })
    local expected = "\x01\x00\x00\x06\x07"
    local actual = seq:pack()
    assert.equal(expected, actual)
  end)
end)

describe("packing deserializes", function()

  describe("byte", function()

    local Byte = Data.byte

    it("without length", function()
      local data = "\x02"
      local expected = 2
      local byte = Byte():unpack(data)
      assert.equal(expected, byte.value)
    end)

    describe("with length", function()

      it("with default size", function()
        local data = "\x01\x00\x00\x00\x04"
        local expected = 4
        local byte = Byte():withlength():unpack(data)
        assert.equal(expected, byte.value)
      end)

      it("with custom size", function()
        local data = "\x01\x00\x06"
        local expected = 6
        local byte = Byte():withlength(2):unpack(data)
        assert.equal(expected, byte.value)
      end)
    end)
  end)

  it("sequence", function()
    local Seq = Data.sequence
    local Byte = Data.byte
    local data = "\x07\x01\x00\x00\x00\x06"
    local expected = { 7, 6 }
    Seq = Seq.withformat({ Byte, Byte.withlength() })
    local seq = Seq.unpack(data)
    assert.equal(expected[1], seq.values[1].value)
    assert.equal(expected[2], seq.values[2].value)
  end)
end)
