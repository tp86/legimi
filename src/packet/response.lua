local ser = require "serializer"
local errors = require(... .. ".errors")

local Auth = {
  serializer = ser.Dictionary {
    [7] = ser.Str, -- sessionid
  },
  unpack = function(self, data)
    local unpacked = self.serializer.unpack(data)
    return {
      sessionid = unpacked[7],
    }
  end,
}

local Activate = {
  serializer = ser.Dictionary {
    [6] = ser.Long, -- deviceid
  },
  unpack = function(self, data)
    local unpacked = self.serializer.unpack(data)
    return {
      deviceid = unpacked[6],
    }
  end,
}

local BookList = {
  serializer = ser.Array(ser.Sequence {
    -- unneeded BEGIN
    ser.RawByte, -- document type
    ser.RawInt, -- length
    ser.RawLong, -- id
    ser.Str, -- name
    ser.RawInt, -- size
    ser.RawLong, -- version
    ser.Str, -- description
    -- unneeded END
    ser.Dictionary {
      [10] = ser.Long, -- id
      [11] = ser.Str, -- title
      [0] = ser.Str, -- author
      [13] = ser.Long, -- version
      [30] = ser.Byte, -- already downloaded
    }
  }),
  unpack = function(self, data)
    local unpacked = self.serializer.unpack(data)
    local booklist = {}
    for _, item in ipairs(unpacked) do
      local bookdata = item[8]
      table.insert(booklist, {
        id = bookdata[10],
        title = bookdata[11],
        author = bookdata[0],
        version = bookdata[13],
        downloaded = bookdata[30] ~= 0,
      })
    end
    return booklist
  end,
}

local BookDetails = {
  serializer = ser.Sequence {
    ser.RawByte, -- compression mode
    ser.RawInt, -- response type
    ser.RawInt, -- number of items (will work only for 1 item)
    ser.RawByte, -- type of item (4 = url)
    ser.Dictionary {
      [0] = ser.Str, -- download url
      --ser.Str, -- filename
      [2] = ser.Long, -- download size
      --[[
      ser.Sequence { -- metadata
        ser.RawByte, -- zipped?
        ser.RawByte, -- to delete?
        ser.RawByte, -- is script?
        ser.RawInt, -- file size
        ser.Str, -- file name with encoded type
        ser.RawByte, -- length of hash
        ser.RawStr, -- file hash -- XXX will not work correctly, as RawStr reads data until end
      }
      --]]
    },
    ser.Str, -- plugin class
    ser.RawLong,
    ser.RawInt,
  },
  unpack = function(self, data)
    local unpacked = self.serializer.unpack(data)
    local downloaddata = unpacked[5]
    return {
      url = downloaddata[0],
      size = downloaddata[2],
    }
  end,
}

local types = setmetatable({
  [16386] = Auth,
  [16384] = Activate,
  [28] = BookList,
  [24] = BookDetails,
}, {
  __index = function(_, msgtype)
    local err = errors[msgtype]
    if err then
      error("Error: " .. err, 0)
    end
    error("Unknown/unsupported response type received: " .. msgtype, 0)
  end,
})

return {
  types = types,
}
