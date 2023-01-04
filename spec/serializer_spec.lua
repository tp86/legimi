---@diagnostic disable: undefined-global

local serializer = require "serializer"

describe("serializer", function()

  describe("simple", function()

    local function test(data, expected, format)
      return function()
        local serialized = serializer.pack(data, format)
        assert.equal(expected, serialized)
      end
    end

    it("can serialize 4 bytes integer value without explicit serializer",
      test(0x14, "\x14\x00\x00\x00"))

    it("can serialize 4 bytes integer value given explicit serializer",
      test(0x24, "\x24\x00\x00\x00", serializer.int))

    it("can serialize 4 bytes integer value preceded by length",
      test(0x34, "\x04\x00\x00\x00\x34\x00\x00\x00", serializer.lenint))

    it("can serialize 2 bytes integer value given serializer",
      test(0x12, "\x12\x00", serializer.short))

    it("can serialize 8 bytes integer value given explicit serializer",
      test(0x18, "\x18\x00\x00\x00\x00\x00\x00\x00", serializer.long))

    it("can serialize 8 bytes integer value preceded by length",
      test(0x28, "\x08\x00\x00\x00\x28\x00\x00\x00\x00\x00\x00\x00", serializer.lenlong))

    it("can serialize string",
      test("abc", "abc"))

    it("can serialize string given explicit serializer",
      test("abc", "abc", serializer.str))

    it("can serialize string preceded by length",
      test("abc", "\x03\x00\x00\x00abc", serializer.lenstr))
  end)

  describe("dictionary", function()

    it("can serialize empty dictionary", function()
      local data = {}
      local expected = "\x00\x00"
      local serialized = serializer.dict(data, format)
      assert.equal(expected, serialized)
    end)
  end)
end)

describe("deserializer", function()

  describe("simple", function()

    local function test(serialized, expected, format)
      return function()
        local deserialized = { serializer.unpack(serialized, format) }
        assert.same(expected, deserialized)
      end
    end

    it("can deserialize 4 bytes integer value",
      test("\x31\x00\x00\x00", { 0x31 }))

    it("can deserialize 4 bytes integer value given explicit serializer",
      test("\x32\x00\x00\x00", { 0x32 }, serializer.int))

    it("can deserialize 4 bytes integer value preceded by length",
      test("\x04\x00\x00\x00\x33\x00\x00\x00", { 4, 0x33 }, serializer.lenint))

    it("can deserialize 2 bytes integer value",
      test("\x41\x00", { 0x41 }, serializer.short))

    it("can deserialize 8 bytes integer value given explicit serializer",
      test("\x18\x00\x00\x00\x00\x00\x00\x00", { 0x18 }, serializer.long))

    it("can deserialize 8 bytes integer value preceded by length",
      test("\x08\x00\x00\x00\x28\x00\x00\x00\x00\x00\x00\x00", { 8, 0x28 }, serializer.lenlong))

    it("can deserialize string given explicit serializer",
      test("abc", { "abc" }, serializer.str))

    it("can deserialize string preceded by length",
      test("\x03\x00\x00\x00abc", { 3, "abc" }, serializer.lenstr))
  end)
end)
