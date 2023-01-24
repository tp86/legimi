---@diagnostic disable: undefined-global

local data = require "data"

local function test(what)
  local description = what.description
  local dataclass = what.class
  local serialized = what.serialized
  local deserialized = what.deserialized

  describe(description, function()

    it("can be created without value", function()
      local object = dataclass()
      assert.is_not_nil(object)
      assert.is_nil(object.value)
    end)

    it("can be created with value", function()
      local value = 1
      local object = dataclass(value)
      assert.equal(value, object.value)
    end)

    it("value can be set after creation", function()
      local object = dataclass()
      assert.is_nil(object.value)
      local value = 2
      object:set(value)
      assert.equal(value, object.value)
    end)

    it("can be serialized", function()
      local object = dataclass(deserialized)
      local expected = serialized
      local actual = object:pack()
      assert.equal(expected, actual)
    end)

    it("can be deserialized", function()
      local object = dataclass()
      local value = serialized
      local expected = deserialized
      object:unpack(value)
      assert.equal(expected, object.value)
    end)
  end)
end

test {
  description = "byte",
  class = data.Byte,
  serialized = "\x03",
  deserialized = 3,
}

test {
  description = "short",
  class = data.Short,
  serialized = "\x03\x04",
  deserialized = 0x0403,
}

test {
  description = "int",
  class = data.Int,
  serialized = "\x03\x04\x05\x06",
  deserialized = 0x06050403,
}

test {
  description = "long",
  class = data.Long,
  serialized = "\x03\x04\x05\x06\x07\x08\x09\x0a",
  deserialized = 0x0a09080706050403,
}

test {
  description = "byte with length",
  class = data.LenByte,
  serialized = "\x01\x00\x00\x00\x03",
  deserialized = 3,
}