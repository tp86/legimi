local http = require('http.request')

local function getbookids()
  local bookids = {}
  for _, a in ipairs(arg) do
    bookids[#bookids + 1] = a
  end
  return bookids
end

local function getenvvar(envvar)
  return assert(os.getenv(envvar), 'Please set ' .. envvar .. ' variable!')
end

local function getlogin()
  return getenvvar('LEGIMI_LOGIN')
end

local function getpass()
  return getenvvar('LEGIMI_PASS')
end

local url = 'https://app.legimi.pl/svc/sync/core.aspx'
local version = '1.3.4 Windows'

local function printbs(s)
  for b = 1, #s, 16 do
    local chunk = table.pack(s:byte(b, b + 15))
    local len = #chunk
    print(string.format(string.rep("%02x ", len), table.unpack(chunk)))
  end
end

local function ntobytes(n, bytes)
  bytes = bytes or 4
  local packfmt = "<i" .. bytes
  return string.pack(packfmt, n)
end

local function part(n, content)
  return {
    ntobytes(n, 2),
    ntobytes(#content),
    content,
  }
end

local function makerequestdata(dataparts, withlength)
  local partsbytes = {}
  for _, part in ipairs(dataparts) do
    if type(part) == 'table' then
      part = table.concat(part)
    end
    partsbytes[#partsbytes + 1] = part
  end
  if withlength then
    return table.concat {
      ntobytes(#dataparts, 2),
      table.unpack(partsbytes),
    }
  else
    return table.concat(partsbytes)
  end
end

local function parseresponse(responseparts)
  local numberofparts = string.unpack("<i2", string.sub(responseparts, 1, 2))
  responseparts = string.sub(responseparts, 3)
  local parts = {}
  local function parsepart(parts)
    local partnumber = string.unpack("<i2", parts)
    local length = string.unpack("<i4", string.sub(parts, 3))
    local content = string.sub(parts, 7, 6 + length)
    return partnumber, content, 6 + length
  end

  for _ = 1, numberofparts do
    local partnumber, content, consumed = parsepart(responseparts)
    responseparts = string.sub(responseparts, consumed + 1)
    parts[partnumber] = content
  end
  return parts
end

local function send(requestdata)
  local request = http.new_from_uri(url)
  request.headers:upsert(':method', 'POST')
  request:set_body(requestdata)
  local headers, stream = request:go()
  assert(headers:get(':status') == '200', 'request failed')
  return stream
end

local function gettoken(login, password)
  local requestdata = table.concat {
    '\x11\x00\x00\x00\x50\x00\x62\x00\x00\x00',
    makerequestdata({
      part(4, string.rep('\x00', 4)),
      part(2, '\x57\xc1\x1b\x00\x00\x00\x00\x00'),
      part(3, version),
      part(1, password),
      part(0, login),
      part(5, string.rep('\x00', 8)),
    }, true)
  }

  local stream = send(requestdata)
  local response = stream:get_body_as_string()
  return parseresponse(response:sub(11))[7]
end

local function downloadbook(token, bookid)
  local requestdata = table.concat {
    '\x11\x00\x00\x00\xc8\x00\x40\x00\x00\x00',
    makerequestdata {
      ntobytes(bookid, 8),
      part(2, ''),
      '\x00\x00',
      token,
      '\x00\x00',
      string.rep('\xff', 8),
      part(1, ''),
    }
  }

  local stream = send(requestdata)
  local response = stream:get_body_as_string()
  local responseparts = parseresponse(response:sub(21))

  local downloadsize, downloadurl = string.unpack("<i8", responseparts[2]), responseparts[0]

  local function getrange(from, length)
    return from, math.min(from + 81920, length) - 1
  end

  local file = assert(io.open(bookid .. '.mobi', 'w+'))
  local from = 0
  io.write('Downloading book ' .. bookid .. ' ')
  io.flush()
  repeat
    local to
    from, to = getrange(from, downloadsize)
    local chunksize = to - from + 1
    local request = http.new_from_uri(downloadurl)
    request.headers:append('range', string.format('bytes=%d-%d', from, to))
    local headers, stream = request:go()
    assert(headers:get(':status') == '200', 'download part failed')
    local response = stream:get_body_as_string()
    file:write(response)
    io.write('.')
    io.flush()
    from = to + 1
  until chunksize < 81920
  file:close()
  io.write(' ok\n')
  io.flush()
end

local login = getlogin()
local pass = getpass()
local token = gettoken(login, pass)

local bookids = getbookids()
for _, bookid in ipairs(bookids) do
  downloadbook(token, bookid)
end
