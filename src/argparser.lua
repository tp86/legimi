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

return parser
