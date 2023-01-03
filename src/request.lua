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

local url = "https://app.legimi.pl/svc/sync/core.aspx"

local function post(data)
  return request(url, "POST"):setbody(data):send()
end

return {
  post = post,
}
