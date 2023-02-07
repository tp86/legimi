local lu = require "luaunit"

local flow = require "flow"

local data = require "test.data"
local withfile = require "util".withfile
local config = require "config"

Test_flow = {

  test_get_session_id = function()
    local sessionid = flow.getsessionid()
    lu.assert_equals(#sessionid, 32)
  end,

  test_get_device_id = function()
    local deviceid = flow.getdeviceid(data.serialno)
    lu.assert_equals(deviceid, data.deviceid)
  end,

  test_device_id = function()
    flow.deviceid(data.serialno)
    local deviceid
    withfile(config.deviceidfilename, "r")(function(file)
      deviceid = file:read("n")
    end)
    lu.assert_equals(deviceid, data.deviceid)
  end,

  test_get_book_list = function()
    local sessionid = flow.getsessionid()
    local books = flow.listbooks(sessionid)
    lu.assert_true(#books > 0)
  end,

  test_get_book = function()
    local sessionid = flow.getsessionid()
    local book = flow.getbook(sessionid, data.bookid)
    lu.assert_equals(book.id, data.bookid)
    lu.assert_equals(book.title, data.booktitle)
    lu.assert_equals(book.version, data.bookversion)
  end,

  test_get_book_details = function()
    local sessionid = flow.getsessionid()
    local details = flow.getbookdetails(sessionid, data.bookid)
    print(details.size, details.url)
  end,
}

local runner = not ... or #arg > 0
if runner then
  os.exit(lu.LuaUnit.run())
end
