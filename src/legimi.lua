local function newrequest(url, method)
  local request = require('http.request').new_from_uri(url)
  request.setbody = function(req, body)
    req:set_body(body)
    return req
  end
  request.send = function(req)
    local _, stream = req:go()
    stream.getbody = stream.get_body_as_string
    stream.savetofile = stream.save_body_to_file
    return stream
  end
  if method then
    request.headers:upsert(':method', method)
  end
  return request
end

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

local function printbs(s) ---@diagnostic disable-line: unused-local, unused-function
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
  return table.concat {
    ntobytes(n, 2),
    ntobytes(#content),
    content,
  }
end

local function parseresponseparts(responseparts)
  local function splitafter(s, n)
    return s:sub(1, n), s:sub(n + 1)
  end

  local function unpackin(from, n)
    local field, rest = splitafter(from, n)
    return string.unpack('<i' .. n, field), rest
  end

  local function parsepart(parts)
    local partnumber, rest = unpackin(parts, 2)
    local length, rest = unpackin(rest, 4)
    local content, rest = splitafter(rest, length)
    return partnumber, content, rest
  end

  local numberofparts, rest = unpackin(responseparts, 2)
  local parts = {}
  for _ = 1, numberofparts do
    local partnumber, content
    partnumber, content, rest = parsepart(rest)
    parts[partnumber] = content
  end
  return parts
end

local function gettoken(login, password)
  local parts = {
    part(4, string.rep('\x00', 4)),
    part(2, '\x57\xc1\x1b\x00\x00\x00\x00\x00'),
    part(3, version),
    part(1, password),
    part(0, login),
    part(5, string.rep('\x00', 8)),
  }
  local requestdata = table.concat {
    '\x11\x00\x00\x00\x50\x00\x62\x00\x00\x00',
    ntobytes(#parts, 2),
    table.unpack(parts),
  }

  local request = newrequest(url, 'POST'):setbody(requestdata)
  local parsedresponse = parseresponseparts(request:send():getbody():sub(11))
  return parsedresponse[7]
end

local function getbookdetails(token, bookid)
  local requestdata = table.concat {
    '\x11\x00\x00\x00\xc8\x00\x40\x00\x00\x00',
    ntobytes(bookid, 8),
    part(2, ''),
    '\x00\x00',
    token,
    '\x00\x00',
    string.rep('\xff', 8),
    part(1, ''),
  }

  local request = newrequest(url, 'POST'):setbody(requestdata)
  local parsedresponse = parseresponseparts(request:send():getbody():sub(21))
  return parsedresponse[0], --[[url]]
      string.unpack('<i8', parsedresponse[2]) --[[size]]
end

local function multipartdownload(url, size, outputfile)
  local partsize = 81920
  local function getrange(from, length)
    return from, math.min(from + partsize, length) - 1
  end

  ---@diagnostic disable-next-line: unbalanced-assignments
  local from, to = 0
  repeat
    from, to = getrange(from, size)
    local chunksize = to - from + 1
    local request = newrequest(url)
    request.headers:append('range', string.format('bytes=%d-%d', from, to))
    request:send():savetofile(outputfile)
    --outputfile:write(request:send():getbody())
    io.output():write('.'):flush()
    from = to + 1
  until chunksize < partsize
end

local function downloadbook(token, bookid)
  local downloadurl, downloadsize = getbookdetails(token, bookid)
  local file <close>              = assert(io.open(bookid .. '.mobi', 'w+'))
  io.output():write('Downloading book ' .. bookid .. ' '):flush()
  multipartdownload(downloadurl, downloadsize, file)
  io.output():write(' ok\n'):flush()
end

local login = getlogin()
local pass = getpass()
local bookids = getbookids()
local token = gettoken(login, pass)
for _, bookid in ipairs(bookids) do
  downloadbook(token, bookid)
end
