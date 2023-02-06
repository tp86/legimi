local withfile = require "util".withfile

local function getenv(name)
  local value = os.getenv(name)
  if not value then
    error("Please set " .. name .. " environment variable", 0)
  end
  return value
end

local function getlogin()
  return getenv("LEGIMI_LOGIN")
end

local function getpassword()
  return getenv("LEGIMI_PASS")
end

local deviceidfilename = "deviceid"

local function getdeviceid()
  local value
  withfile(deviceidfilename, "r")(function(file)
    if not file then
      error("Please create " .. deviceidfilename .. " file with your Device ID", 0)
    end
    value = file:read("n")
    if not value then
      error("Couldn't read Device ID from " .. deviceidfilename, 0)
    end
  end)
  return value
end

local lazyload = {
  login = getlogin,
  password = getpassword,
  deviceid = getdeviceid,
}

return setmetatable({
  packetversion = 17,
  appversion = "1.5.0 Windows",
  url = "https://app.legimi.pl/svc/sync/core.aspx",
  deviceidfilename = deviceidfilename,
}, {
  __index = function(cfg, key)
    local value = lazyload[key]()
    if value then
      cfg[key] = value
      return value
    end
  end,
})
