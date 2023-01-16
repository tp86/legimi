local serializer = require "serializer"
local requests = {}
requests.auth = {
  type = 80,
  fields = {
    user = 0,
    password = 1,
    deviceid = 2,
    appversion = 3,
  },
  constants = {
    appversion = "1.5.0 Windows",
  },
}
requests.auth.format = serializer.dict {
  [requests.auth.fields.user] = serializer.str,
  [requests.auth.fields.password] = serializer.str,
  [requests.auth.fields.deviceid] = serializer.lenlong,
  [requests.auth.fields.appversion] = serializer.str,
}

requests.booklist = {
  type = 26,
  fields = {
    filtercount = 1,
    sessionid = 2,
    filterdata = 3,
  },
  constants = {
    documentlistfilter = 0x02,
    documentcontenttype = 0x0e,
    contenttypelength = 2,
    mobicontenttype = 0x08,
  }
}
requests.booklist.format = {
  [requests.booklist.fields.filtercount] = serializer.byte,
  [requests.booklist.fields.sessionid] = serializer.bytes(32),
  [requests.booklist.fields.filterdata] = { { -- sequence of sequences?
    serializer.byte, -- list filter type (from AbstractQueryFilter.readFilter, 2 = DocumentListFilter)
    serializer.short, -- filter type
    serializer.short, -- len of content type
    serializer.short, -- DocumentContentType
  } }
}
local packet = require "packet.generic"

local function makeauthreq(login, password, deviceid)
  local req = requests.auth
  local fields = req.fields
  local data = {
    [fields.user] = login,
    [fields.password] = password,
    [fields.deviceid] = deviceid,
    [fields.appversion] = req.constants.appversion,
  }
  local content = serializer.pack(data, req.format)
  return packet.make(req.type, content)
end

local function makebooklistreq(sessionid)
  local req = requests.booklist
  local fields = req.fields
  local const = req.constants
  local filters = {
    {
      const.documentlistfilter,
      const.documentcontenttype,
      const.contenttypelength,
      const.mobicontenttype,
    }
  }
  local data = {
    [fields.filtercount] = #filters,
    [fields.sessionid] = sessionid,
    [fields.filterdata] = filters,
  }
  local content = serializer.pack(data, req.format)
  return packet.make(req.type, content)
end

return {
  auth = makeauthreq,
  booklist = makebooklistreq,
}
