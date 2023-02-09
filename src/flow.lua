local config = require "config"
local post = require "http".post
local get = require "http".get
local packet = require "packet"
local request = require "packet.request"
local withfile = require "util".withfile
local ranges = require "util".ranges
local formatbook = require "util".formatbook

local function exchange(requestbody)
  local response = post(requestbody):getbody()
  return packet.unpack(response)
end

local function getsessionid()
  local login = config.login
  local password = config.password
  local deviceid = config.deviceid
  local response = exchange(request.Auth:pack(login, password, deviceid))
  local sessionid = response.sessionid
  return sessionid
end

local function getdeviceid(serialno)
  local login = config.login
  local password = config.password
  local response = exchange(request.Activate:pack(login, password, serialno))
  local deviceid = response.deviceid
  return deviceid
end

local function storedeviceid(deviceid)
  withfile(config.deviceidfilename, "w")(function(file)
    if not file:write(deviceid) then
      error("Error writing Device ID to " .. config.deviceidfilename)
    end
  end)
end

local function getandstoredeviceid(serialno)
  local deviceid = getdeviceid(serialno)
  storedeviceid(deviceid)
end

local function listbooks(sessionid)
  local response = exchange(request.BookList:pack(sessionid))
  for _, book in ipairs(response) do
    print(formatbook(book))
  end
end

local function getbook(sessionid, bookid)
  local response = exchange(request.Book:pack(sessionid, bookid))
  return response[1]
end

local function getbookdetails(sessionid, bookid)
  local version = getbook(sessionid, bookid).version
  local response = exchange(request.BookDetails:pack(sessionid, bookid, version))
  return response
end

local function downloadbook(sessionid, bookid)
  local bookdetails = getbookdetails(sessionid, bookid)
  io.output():write("Downloading book " .. bookid .. " "):flush()
  withfile(bookid .. ".mobi", "w")(function(file)
    for from, to in ranges(bookdetails.size) do
      get { { "range", string.format("bytes=%d-%d", from, to) } }:savetofile(file)
      io.output():write("."):flush()
    end
  end)
  io.output():write(" ok\n"):flush()
end

return {
  getsessionid = getsessionid,
  getdeviceid = getdeviceid,
  deviceid = getandstoredeviceid,
  listbooks = listbooks,
  getbook = getbook,
  getbookdetails = getbookdetails,
  downloadbook = downloadbook,
}
