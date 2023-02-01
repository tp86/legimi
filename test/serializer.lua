local lu = require "luaunit"

local serializers = require "serializer"

local function testnumber(what)
  local classname = what.class
  local serialized = what.serialized
  local deserialized = what.deserialized

  _ENV["Test_" .. classname] = {

    test_can_serialize_value = function()
      local serializer = serializers[classname]
      lu.assert_equals(serializer.pack(deserialized), serialized)
    end,

    test_can_deserialize_value = function()
      local serializer = serializers[classname]
      lu.assert_equals(serializer.unpack(serialized), deserialized)
    end,
  }
end

testnumber {
  class = "RawByte",
  serialized = "\x03",
  deserialized = 3,
}

testnumber {
  class = "RawShort",
  serialized = "\x03\x04",
  deserialized = 0x0403,
}

testnumber {
  class = "RawInt",
  serialized = "\x03\x04\x05\x06",
  deserialized = 0x06050403,
}

testnumber {
  class = "RawLong",
  serialized = "\x03\x04\x05\x06\x07\x08\x09\x0a",
  deserialized = 0x0a09080706050403,
}

testnumber {
  class = "Byte",
  serialized = "\x01\x00\x00\x00\x03",
  deserialized = 3,
}

testnumber {
  class = "Short",
  serialized = "\x02\x00\x00\x00\x03\x04",
  deserialized = 0x0403,
}

testnumber {
  class = "Int",
  serialized = "\x04\x00\x00\x00\x03\x04\x05\x06",
  deserialized = 0x06050403,
}

testnumber {
  class = "Long",
  serialized = "\x08\x00\x00\x00\x03\x04\x05\x06\x07\x08\x09\x0a",
  deserialized = 0x0a09080706050403,
}

local Str = serializers.Str

Test_string_with_length = {

  test_can_serialize_value = function()
    local value = "abc"
    local expected = "\x03\x00\x00\x00abc"
    local actual = Str.pack(value)
    lu.assert_equals(actual, expected)
  end,

  test_can_deserialize_value = function()
    local value = "\x04\x00\x00\x00abcd"
    local expected = "abcd"
    local actual = Str.unpack(value)
    lu.assert_equals(actual, expected)
  end,
}

local Seq = serializers.Sequence

Test_sequence = {

  test_can_serialize_values = function()
    local seq = Seq { serializers.RawByte, serializers.Short }
    local expected = "\x05\x02\x00\x00\x00\x06\x00"
    local actual = seq.pack({ 5, 6 })
    lu.assert_equals(actual, expected)
  end,

  test_can_deserialize_values = function()
    local seq = Seq { serializers.Byte, serializers.RawShort }
    local value = "\x01\x00\x00\x00\x07\x08\x00"
    local expected = { 7, 8 }
    local actual = seq.unpack(value)
    lu.assert_equals(actual, expected)
  end,
}

local nested = Seq { serializers.RawByte, serializers.RawByte }

Test_sequence_nested = {

  test_can_serialize_values = function()
    local seq = Seq { nested, serializers.RawShort }
    local expected = "\x08\x09\x0a\x00"
    local actual = seq.pack({ { 8, 9 }, 10 })
    lu.assert_equals(actual, expected)
  end,

  test_can_deserialize_values = function()
    local seq = Seq { serializers.RawByte, nested, serializers.RawByte }
    local value = "\x0b\x0c\x0d\x0e"
    local expected = { 11, { 12, 13 }, 14 }
    local actual = seq.unpack(value)
    lu.assert_equals(actual, expected)
  end,
}

local Arr = serializers.Array

Test_array = {

  test_can_serialize_values = function()
    local arr = Arr(serializers.RawShort)
    local expected = "\x02\x00\x11\x22\x33\x44"
    local actual = arr.pack({ 0x2211, 0x4433 })
    lu.assert_equals(actual, expected)
  end,

  test_can_deserialize_values = function()
    local arr = Arr(serializers.RawByte)
    local value = "\x02\x00\x03\x04"
    local expected = { 3, 4 }
    local actual = arr.unpack(value)
    lu.assert_equals(actual, expected)
  end,
}

Test_array_nested = {

  test_can_serialize_values = function()
    local arr = Arr(Arr(serializers.RawByte))
    local expected = "\x01\x00\x01\x00\x02"
    local actual = arr.pack({ { 2 } })
    lu.assert_equals(actual, expected)
  end,

  test_can_deserialize_values = function()
    local arr = Arr(Arr(serializers.RawByte))
    local value = "\x01\x00\x01\x00\x03"
    local expected = { { 3 } }
    local actual = arr.unpack(value)
    lu.assert_equals(actual, expected)
  end,
}

local Dict = serializers.Dictionary

Test_dictionary = {

  test_can_serialize_values = function()
    local dict = Dict { [0] = serializers.RawByte, serializers.Int }
    local expectedparts = {
      "\x00\x00\x01",
      "\x01\x00\x04\x00\x00\x00\x02\x00\x00\x00",
    }
    local actual = dict.pack { [0] = 1, 2, 3 }
    lu.assert_equals(actual:sub(1, 2), "\x02\x00")
    for _, part in ipairs(expectedparts) do
      lu.assert_str_contains(actual, part)
    end
  end,

  test_can_deserialize_values = function()
    local dict = Dict { [0] = serializers.Byte, serializers.Short }
    local value = "\x02\x00\x01\x00\x02\x00\x00\x00\x03\x00\x00\x00\x01\x00\x00\x00\x04"
    local expected = { [0] = 4, 3 }
    local actual = dict.unpack(value)
    lu.assert_equals(actual, expected)
  end,

  test_can_deserialize_unknown_key_given_length = function()
    local dict = Dict { [0] = serializers.RawByte }
    local value = "\x01\x00\x01\x00\x01\x00\x00\x00\x03"
    local expected = { "\x03" }
    local actual = dict.unpack(value)
    lu.assert_equals(actual, expected)
  end,
}

Test_dictionary_nested = {

  test_can_serialize_values = function()
    local dict = Dict { [0] = Dict { serializers.RawByte }, serializers.Short }
    local expectedparts = {
      "\x00\x00\x01\x00\x01\x00\x03",
      "\x01\x00\x02\x00\x00\x00\x04\x00",
    }
    local actual = dict.pack { [0] = { 3 }, 4 }
    lu.assert_equals(actual:sub(1, 2), "\x02\x00")
    for _, part in ipairs(expectedparts) do
      lu.assert_str_contains(actual, part)
    end
  end,

  test_can_deserialize_values = function()
    local dict = Dict { [0] = Dict { serializers.RawByte }, serializers.RawByte }
    local value = "\x02\x00\x00\x00\x01\x00\x01\x00\x01\x01\x00\x02"
    local expected = { [0] = { 1 }, 2 }
    local actual = dict.unpack(value)
    lu.assert_equals(actual, expected)
  end,
}

Test_compound = {

  test_serialize_sequence_starting_with_string = function()
    local seq = Seq { serializers.Str, serializers.Byte }
    local expected = "\x01\x00\x00\x00a\x01\x00\x00\x00\x99"
    local actual = seq.pack({ "a", -103 })
    lu.assert_equals(actual, expected)
  end,

  test_deserialize_sequence_starting_with_string = function()
    local seq = Seq { serializers.Str, serializers.Byte }
    local expected = { "a", -103 }
    local actual = seq.unpack("\x01\x00\x00\x00a\x01\x00\x00\x00\x99")
    lu.assert_equals(actual, expected)
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
