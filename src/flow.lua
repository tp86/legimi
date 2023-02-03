local config = require "config"
local getlogin = config.getlogin
local getpassword = config.getpassword
local getdeviceid = config.getdeviceid
local post = require "http".post
local requests = require "data.request"
local Auth = requests.Auth
local packet = require "packet"

local function getsessionid()
  local login = getlogin()
  local password = getpassword()
  local deviceid = getdeviceid()
  local requestpacket = Auth:pack(login, password, deviceid)
  local responsepacket = post(requestpacket):getbody()
  local response = packet.unpack(responsepacket)
  local sessionid = response.sessionid
  return sessionid
end

return {
  getsessionid = getsessionid,
}
