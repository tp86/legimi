local lu = require "luaunit"

local data = require "data"

local function testnumber(what)
  local description = what.description
  local dataclass = what.class
  local serialized = what.serialized
  local deserialized = what.deserialized

  _ENV["Test_" .. description] = {

    test_can_be_created_without_value = function()
      local object = dataclass()
      lu.assert_not_nil(object)
      lu.assert_nil(object.value)
    end,

    test_can_be_created_with_value = function()
      local value = 1
      local object = dataclass(value)
      lu.assert_equals(object.value, value)
    end,

    test_can_be_set_after_creation = function()
      local object = dataclass()
      lu.assert_nil(object.value)
      local value = 2
      object:set(value)
      lu.assert_equals(object.value, value)
    end,

    test_can_be_serialized = function()
      local object = dataclass(deserialized)
      local expected = serialized
      local actual = object:pack()
      lu.assert_equals(actual, expected)
    end,

    test_can_be_deserialized = function()
      local object = dataclass()
      local value = serialized
      local expected = deserialized
      object:unpack(value)
      lu.assert_equals(object.value, expected)
    end,
  }
end

testnumber {
  description = "byte",
  class = data.Byte,
  serialized = "\x03",
  deserialized = 3,
}

testnumber {
  description = "short",
  class = data.Short,
  serialized = "\x03\x04",
  deserialized = 0x0403,
}

testnumber {
  description = "int",
  class = data.Int,
  serialized = "\x03\x04\x05\x06",
  deserialized = 0x06050403,
}

testnumber {
  description = "long",
  class = data.Long,
  serialized = "\x03\x04\x05\x06\x07\x08\x09\x0a",
  deserialized = 0x0a09080706050403,
}

testnumber {
  description = "byte_with_length",
  class = data.LenByte,
  serialized = "\x01\x00\x00\x00\x03",
  deserialized = 3,
}

testnumber {
  description = "short_with_length",
  class = data.LenShort,
  serialized = "\x02\x00\x00\x00\x03\x04",
  deserialized = 0x0403,
}

testnumber {
  description = "int_with_length",
  class = data.LenInt,
  serialized = "\x04\x00\x00\x00\x03\x04\x05\x06",
  deserialized = 0x06050403,
}

testnumber {
  description = "long_with_length",
  class = data.LenLong,
  serialized = "\x08\x00\x00\x00\x03\x04\x05\x06\x07\x08\x09\x0a",
  deserialized = 0x0a09080706050403,
}

local Seq = data.Sequence

Test_sequence = {

  test_can_be_created_with_types_but_without_values = function()
    local seq = Seq { data.Byte, data.LenLong } ()
    lu.assert_not_nil(seq)
    lu.assert_nil(seq.values)
  end,

  test_can_be_created_with_values = function()
    local seq = Seq { data.Byte, data.LenInt } (1, 2)
    local expected = { 1, 2 }
    lu.assert_equals(seq.values, expected)
  end,

  test_can_have_values_set_after_creating = function()
    local seq = Seq { data.Short, data.Int, data.Byte } ()
    lu.assert_nil(seq.values)
    local values = { 3, nil, 4 }
    seq:set(table.unpack(values))
    lu.assert_equals(seq.values, values)
  end,

  test_can_be_serialized = function()
    local seq = Seq { data.Byte, data.LenShort } (5, 6)
    local expected = "\x05\x02\x00\x00\x00\x06\x00"
    local actual = seq:pack()
    lu.assert_equals(actual, expected)
  end,

  _test_can_be_deserialized = function()
  end,
}

local nested = Seq { data.Byte, data.Byte }

Test_sequence_nested = {

  test_can_be_created = function()
    local seq = Seq { nested } ({ 7, 8 })
    lu.assert_not_nil(seq)
    lu.assert_equals(seq.values, { { 7, 8 } })
  end,

  test_can_be_serialized = function()
    local seq = Seq { nested, data.Short } ({ 8, 9 }, 10)
    local expected = "\x08\x09\x0a\x00"
    local actual = seq:pack()
    lu.assert_equals(actual, expected)
  end,

  _test_can_be_deserialized = function()
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
