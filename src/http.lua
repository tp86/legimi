local function request(url, method)
  local req = require "http.request".new_from_uri(url)
  req.setbody = function(self, body)
    self:set_body(body)
    return self
  end
  req.send = function(self)
    local _, stream = self:go()
    ---@diagnostic disable-next-line: need-check-nil
    stream.getbody = stream.get_body_as_string
    ---@diagnostic disable-next-line: need-check-nil
    stream.savetofile = stream.save_body_to_file
    return stream
  end
  if method then
    req.headers:upsert(":method", method)
  end
  return req
end

local apiurl = require "config".url

local function post(data)
  return request(apiurl, "POST"):setbody(data):send()
end

local function get(url, headers)
  local req = request(url)
  for _, header in ipairs(headers or {}) do
    req.headers:append(table.unpack(header))
  end
  return req:send()
end

return {
  post = post,
  get = get,
}
