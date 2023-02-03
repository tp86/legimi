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

local function getdeviceid()
  local filename = "deviceid"
  local file = io.open(filename, "r")
  if not file then
    error("Please create " .. filename .. " file with your Device ID", 0)
  end
  local value = file:read("n")
  if not value then
    error("Couldn't read Device ID from " .. filename, 0)
  end
  file:close()
  return value
end

return {
  packetversion = 17,
  appversion = "1.5.0 Windows",
  url = "https://app.legimi.pl/svc/sync/core.aspx",
  getlogin = getlogin,
  getpassword = getpassword,
  getdeviceid = getdeviceid,
}
