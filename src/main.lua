local flow = require "flow"

local function withsessionid(func)
  return function(...)
    local sessionid = flow.getsessionid()
    return func(sessionid, ...)
  end
end

local commands = {
  deviceid = {
    func = flow.deviceid,
    args = { "serialno" },
  },
  list = {
    func = withsessionid(flow.listbooks),
  },
  download = {
    func = withsessionid(function(sessionid, ids)
      for _, id in ipairs(ids) do
        flow.downloadbook(sessionid, id)
      end
    end),
    args = { "id" },
  }
}

local function run(args)
  local commandargs = {}
  local command = commands[args.command]
  for _, name in ipairs(command.args or {}) do
    table.insert(commandargs, args[name])
  end
  local ok, err = pcall(command.func, table.unpack(commandargs))
  if not ok then
    print(err)
  end
end

return run
