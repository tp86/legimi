local config = require "config"
local post = require "http".post
local packet = require "packet"
local requests = require "packet.request"
local withfile = require "util".withfile

local function exchange(request)
  local response = post(request):getbody()
  return packet.unpack(response)
end

local function getsessionid()
  local login = config.login
  local password = config.password
  local deviceid = config.deviceid
  local response = exchange(requests.Auth:pack(login, password, deviceid))
  local sessionid = response.sessionid
  return sessionid
end

local function getdeviceid(serialno)
  local login = config.login
  local password = config.password
  local response = exchange(requests.Activate:pack(login, password, serialno))
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
  local response = exchange(requests.BookList:pack(sessionid))
  return response
end

local function getbook(sessionid, bookid)
  local response = exchange(requests.Book:pack(sessionid, bookid))
  return response[1]
end

local function getbookdetails(sessionid, bookid)
  local version = getbook(sessionid, bookid).version
  local response = exchange(requests.BookDetails:pack(sessionid, bookid, version))
  return response
end

return {
  getsessionid = getsessionid,
  getdeviceid = getdeviceid,
  deviceid = getandstoredeviceid,
  listbooks = listbooks,
  getbook = getbook,
  getbookdetails = getbookdetails,
}
