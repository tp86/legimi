---@diagnostic disable: undefined-global
describe("serializer", function()

  local serializer = require "serializer"

  describe("serializes", function()

    describe("a string with length", function()

      it("without explicit format", function()
        local data = "abc"
        local expected = "\x03\x00\x00\x00abc"
        local actual = serializer.pack(data)
        assert.equal(expected, actual)
      end)

      it("with explicit format", function()
        local data = "abc"
        local format = serializer.str
        local expected = "\x03\x00\x00\x00abc"
        local actual = serializer.pack(data, format)
        assert.equal(expected, actual)
      end)
    end)

    describe("a 4-byte integer with length", function()

      it("without explicit format", function()
        local data = 0x11001100
        local expected = "\x04\x00\x00\x00\x00\x11\x00\x11"
        local actual = serializer.pack(data)
        assert.equal(expected, actual)
      end)

      it("with explicit format", function()
        local data = 0x12001200
        local format = serializer.lenint
        local expected = "\x04\x00\x00\x00\x00\x12\x00\x12"
        local actual = serializer.pack(data, format)
        assert.equal(expected, actual)
      end)
    end)

    describe("a 2-byte count without length", function()

      it("with explicit format", function()
        local data = 6
        local format = serializer.count
        local expected = "\x06\x00"
        local actual = serializer.pack(data, format)
        assert.equal(expected, actual)
      end)
    end)

    describe("a dict with numeric keys", function()

      it("with explicit format", function()
        local data = { [0] = 15, [2] = "abc" }
        local format = serializer.dict { [0] = serializer.lenint, [1] = serializer.str, [2] = serializer.str }
        local expected = {
          header = "\x02\x00",
          "\x00\x00\x04\x00\x00\x00\x0f\x00\x00\x00",
          "\x02\x00\x03\x00\x00\x00abc",
        }
        local actual = serializer.pack(data, format)
        local expectedsize = #expected.header
        assert.equal(expected.header, actual:sub(1, #expected.header))
        for _, expecteditem in ipairs(expected) do
          assert.is_truthy(string.find(actual:sub(#expected.header + 1), expecteditem))
          expectedsize = expectedsize + #expecteditem
        end
        assert.equal(expectedsize, #actual)
      end)

      it("nested", function()
        local data = { [0] = { [2] = "abc" } }
        local format = serializer.dict { [0] = serializer.dict { [2] = serializer.str } }
        local expected = "\x01\x00\x00\x00\x01\x00\x02\x00\x03\x00\x00\x00abc"
        local actual = serializer.pack(data, format)
        assert.equal(expected, actual)
      end)
    end)

    describe("a Lua sequence", function()

      it("with explicit format", function()
        local data = { 0x11, "abc" }
        local format = { serializer.lenint, serializer.str }
        local expected = "\x04\x00\x00\x00\x11\x00\x00\x00\x03\x00\x00\x00abc"
        local actual = serializer.pack(data, format)
        assert.equal(expected, actual)
      end)

      it("with nested dict", function()
        local data = { { [2] = 0x22 }, "abc" }
        local format = { serializer.dict { [2] = serializer.count }, serializer.str }
        local expected = "\x01\x00\x02\x00\x22\x00\x03\x00\x00\x00abc"
        local actual = serializer.pack(data, format)
        assert.equal(expected, actual)
      end)
    end)

    describe("an array", function()

      it("with explicit format - simple", function()
        local data = { 0x11, 0x12, 0x13 }
        local format = serializer.array(serializer.int)
        local expected = "\x03\x00\x11\x00\x00\x00\x12\x00\x00\x00\x13\x00\x00\x00"
        local actual = serializer.pack(data, format)
        assert.equal(expected, actual)
      end)

      it("with explicit format - compound", function()
        local data = { { [0] = 0x12 } }
        local format = serializer.array(serializer.dict { [0] = serializer.lenint })
        local expected = "\x01\x00\x01\x00\x00\x00\x04\x00\x00\x00\x12\x00\x00\x00"
        local actual = serializer.pack(data, format)
        assert.equal(expected, actual)
      end)
    end)
  end)

  describe("deserializes", function()

    describe("a string with length", function()

      it("with explicit format", function()
        local data = "\x03\x00\x00\x00abc"
        local format = serializer.str
        local expected = "abc"
        local actual = serializer.unpack(data, format)
        assert.equal(expected, actual)
      end)
    end)

    describe("a 4-byte integer with length", function()

      it("with explicit format", function()
        local data = "\x04\x00\x00\x00\x00\x12\x00\x12"
        local format = serializer.lenint
        local expected = 0x12001200
        local actual = serializer.unpack(data, format)
        assert.equal(expected, actual)
      end)
    end)

    describe("a 2-byte count without length", function()

      it("with explicit format", function()
        local data = "\xff\x00"
        local format = serializer.count
        local expected = 255
        local actual = serializer.unpack(data, format)
        assert.equal(expected, actual)
      end)
    end)

    describe("a dict with numeric keys", function()

      it("with explicit format", function()
        local data = "\x02\x00\x00\x00\x04\x00\x00\x00\x0f\x00\x00\x00\x02\x00\x03\x00\x00\x00abc"
        local format = serializer.dict { [0] = serializer.lenint, [1] = serializer.str, [2] = serializer.str }
        local expected = { [0] = 15, [2] = "abc" }
        local actual = serializer.unpack(data, format)
        assert.same(expected, actual)
      end)

      it("nested", function()
        local data = "\x01\x00\x00\x00\x01\x00\x02\x00\x03\x00\x00\x00abc"
        local format = serializer.dict { [0] = serializer.dict { [2] = serializer.str } }
        local expected = { [0] = { [2] = "abc" } }
        local actual = serializer.unpack(data, format)
        assert.same(expected, actual)
      end)
    end)

    describe("a Lua sequence", function()

      it("with explicit format", function()
        local data = "\x11\x00\x00\x00\x22\x00\x03\x00\x00\x00abc"
        local format = { serializer.int, serializer.key, serializer.str }
        local expected = { 0x11, 0x22, "abc" }
        local actual = serializer.unpack(data, format)
        assert.same(expected, actual)
      end)

      it("with nested dict", function()
        local data = "\x01\x00\x02\x00\x22\x00\x03\x00\x00\x00abc"
        local format = { serializer.dict { [2] = serializer.count }, serializer.str }
        local expected = { { [2] = 0x22 }, "abc" }
        local actual = serializer.unpack(data, format)
        assert.same(expected, actual)
      end)
    end)

    describe("an array", function()

      it("with explicit format - simple", function()
        local data = "\x03\x00\x11\x00\x00\x00\x12\x00\x00\x00\x13\x00\x00\x00"
        local format = serializer.array(serializer.int)
        local expected = { 0x11, 0x12, 0x13 }
        local actual = serializer.unpack(data, format)
        assert.same(expected, actual)
      end)

      it("with explicit format - compound", function()
        local data = "\x01\x00\x01\x00\x00\x00\x04\x00\x00\x00\x12\x00\x00\x00"
        local format = serializer.array(serializer.dict { [0] = serializer.lenint })
        local expected = { { [0] = 0x12 } }
        local actual = serializer.unpack(data, format)
        assert.same(expected, actual)
      end)
    end)
  end)
end)
