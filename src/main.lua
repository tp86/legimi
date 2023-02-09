local parser = require "argparse"()

parser:name "legimi"
parser:description
"Unofficial Legimi for Kindle ebook downloader."

parser:command_target "command"

local deviceid = parser:command "deviceid"
deviceid:summary
"Get and store Device ID."
deviceid:description
[[Get the Device ID associated with your Kindle and store it in `deviceid` file for future.
It should be invoked only once.
If you have your Device ID obtained in different way, you can just put it in `deviceid` file.]]
deviceid:argument("serialno", "Your Kindle serial number.")

local list = parser:command "list"
list:summary
"List books on the user's shelf."
list:description
[[Print list of books that are added to user's shelf.

Books are printed in following format:

  {bookid}: {title}, {author}, downloaded: true|false

{bookid} is used to identify book to be downloaded with `download` command.
`downloaded` shows whether book was already downloaded. Already downloaded books should not affect download limit.]]

local download = parser:command "download"
download:summary
"Download book(s)"
download:description
[[Download books identified by given ids.
Book id can be obtained using `list` command or copied from url of book's legimi page.

Books are saved with `{id}.mobi` name.]]
download:argument("id", "Id(s) of book(s) to download"):args("+")

local args = parser:parse()

local flow = require "flow"

local function withsessionid(func)
  local sessionid = flow.getsessionid()
  return function(...)
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

run(args)
