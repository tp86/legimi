local config = require "config"
local post = require "http".post
local requests = require "data.request"
local Auth = requests.Auth
local Activate = requests.Activate
local packet = require "packet"
local withfile = require "util".withfile

local function exchange(request)
  local response = post(request):getbody()
  return packet.unpack(response)
end

local function getsessionid()
  local login = config.login
  local password = config.password
  local deviceid = config.deviceid
  local response = exchange(Auth:pack(login, password, deviceid))
  local sessionid = response.sessionid
  return sessionid
end

local function getdeviceid(serialno)
  local login = config.login
  local password = config.password
  local response = exchange(Activate:pack(login, password, serialno))
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

return {
  getsessionid = getsessionid,
  getdeviceid = getdeviceid,
  deviceid = getandstoredeviceid,
}
