local lu = require "luaunit"

local data = require "data"

local function testnumber(what)
  local classname = what.class
  local serialized = what.serialized
  local deserialized = what.deserialized

  _ENV["Test_" .. classname] = {

    test_can_serialize_value = function()
      local serializer = data[classname]
      lu.assert_equals(serializer.pack(deserialized), serialized)
    end,

    test_can_deserialize_value = function()
      local serializer = data[classname]
      lu.assert_equals(serializer.unpack(serialized), deserialized)
    end,
  }
end

testnumber {
  class = "Byte",
  serialized = "\x03",
  deserialized = 3,
}

testnumber {
  class = "Short",
  serialized = "\x03\x04",
  deserialized = 0x0403,
}

testnumber {
  class = "Int",
  serialized = "\x03\x04\x05\x06",
  deserialized = 0x06050403,
}

testnumber {
  class = "Long",
  serialized = "\x03\x04\x05\x06\x07\x08\x09\x0a",
  deserialized = 0x0a09080706050403,
}

testnumber {
  class = "LenByte",
  serialized = "\x01\x00\x00\x00\x03",
  deserialized = 3,
}

testnumber {
  class = "LenShort",
  serialized = "\x02\x00\x00\x00\x03\x04",
  deserialized = 0x0403,
}

testnumber {
  class = "LenInt",
  serialized = "\x04\x00\x00\x00\x03\x04\x05\x06",
  deserialized = 0x06050403,
}

testnumber {
  class = "LenLong",
  serialized = "\x08\x00\x00\x00\x03\x04\x05\x06\x07\x08\x09\x0a",
  deserialized = 0x0a09080706050403,
}

local Seq = data.Sequence

Test_sequence = {

  test_can_serialize_values = function()
    local seq = Seq { data.Byte, data.LenShort }
    local expected = "\x05\x02\x00\x00\x00\x06\x00"
    local actual = seq.pack({ 5, 6 })
    lu.assert_equals(actual, expected)
  end,

  test_can_deserialize_values = function()
    local seq = Seq { data.LenByte, data.Short }
    local value = "\x01\x00\x00\x00\x07\x08\x00"
    local expected = { 7, 8 }
    local actual = seq.unpack(value)
    lu.assert_equals(actual, expected)
  end,
}

local nested = Seq { data.Byte, data.Byte }

Test_sequence_nested = {

  test_can_serialize_values = function()
    local seq = Seq { nested, data.Short }
    local expected = "\x08\x09\x0a\x00"
    local actual = seq.pack({ { 8, 9 }, 10 })
    lu.assert_equals(actual, expected)
  end,

  test_can_deserialize_values = function()
    local seq = Seq { data.Byte, nested, data.Byte }
    local value = "\x0b\x0c\x0d\x0e"
    local expected = { 11, { 12, 13 }, 14 }
    local actual = seq.unpack(value)
    lu.assert_equals(actual, expected)
  end,
}

local Arr = data.Array

Test_array = {

}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
