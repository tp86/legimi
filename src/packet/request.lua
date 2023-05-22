local ser = require "serializer"
local packet = require "packet"

local appversion = require "config".appversion

local function packrequest(request, data)
  local content = request.serializer.pack(data)
  return packet.serializer.pack({ packet.version, request.type, content })
end

local Auth = {
  type = 80,
  serializer = ser.Dictionary {
    [0] = ser.Str, -- login
    ser.Str, -- password
    ser.Long, -- deviceid
    ser.Str -- appversion
  },
  pack = function(self, login, password, deviceid)
    return packrequest(self, { [0] = login, password, deviceid, appversion })
  end,
}

local Activate = {
  type = 66,
  serializer = ser.Sequence {
    ser.RawLong, -- empty device id
    ser.ShortStr, -- login
    ser.ShortStr, -- password
    ser.ShortStr, -- serial number
    ser.ShortStr, -- locale
  },
  pack = function(self, login, password, serialno)
    local deviceid = 0
    serialno = "Kindle||Kindle||" .. serialno .. "||Kindle"
    local locale = ""
    return packrequest(self, { deviceid, login, password, serialno, locale })
  end,
}

local filterlisttypes = {
  documentlist = 2,
}

local filtertypes = {
  acceptedformats = 14,
  idequal = 10,
}

local formats = {
  mobi = 8,
}

local bookrequest = {
  type = 26,
  serializer = ser.Sequence {
    ser.RawByte, -- number of filters
    ser.RawStr, -- session id
    ser.Sequence {
      ser.RawByte, -- filter list type
      ser.RawShort, -- filter type
      ser.RawStr, -- filter argument
    }
  },
  pack = function(self, sessionid)
    local filtercount = #self.filter / 3
    return packrequest(self, { filtercount, sessionid, self.filter })
  end,
}

local bookrequestmt = {
  __index = bookrequest,
}

local BookList = setmetatable({
  filter = {
    filterlisttypes.documentlist,
    filtertypes.acceptedformats,
    ser.ShortShort.pack(formats.mobi),
  }
}, bookrequestmt)

local Book = setmetatable({
  filter = {
    filterlisttypes.documentlist,
    filtertypes.acceptedformats,
    ser.ShortShort.pack(formats.mobi),
    filterlisttypes.documentlist,
    filtertypes.idequal,
  },
  serializer = ser.Sequence {
    ser.RawByte, -- number of filters
    ser.RawStr, -- session id
    ser.Sequence {
      ser.RawByte, -- filter list type
      ser.RawShort, -- filter type
      ser.RawStr, -- filter argument
      ser.RawByte, -- filter list type
      ser.RawShort, -- filter type
      ser.RawStr, -- filter argument
    }
  },
  pack = function(self, sessionid, bookid)
    table.insert(self.filter, ser.ShortLong.pack(bookid))
    return bookrequest.pack(self, sessionid)
  end,
}, bookrequestmt)

local BookDetails = {
  type = 200,
  serializer = ser.Sequence {
    ser.RawLong, -- book id
    ser.RawLong, -- book version
    ser.RawStr, -- session id
    ser.RawByte, -- get miniature?
    ser.RawByte, -- get metadata only?
    ser.RawLong, -- current version
    ser.Array(ser.RawShort), -- whole parts
    ser.Array(ser.RawShort), -- part fragments
  },
  pack = function(self, sessionid, bookid, bookversion)
    local no = 0
    local currentversion = -1
    return packrequest(self, {
      bookid,
      bookversion,
      sessionid,
      no,
      no,
      currentversion,
      { 0 },
      {},
    })
  end
}

return {
  Auth = Auth,
  Activate = Activate,
  BookList = BookList,
  Book = Book,
  BookDetails = BookDetails,
}
