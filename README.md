# legimi
Unofficial Legimi ebook downloader for Kindle

This is Legimi ebook downloader made for downloading ebooks for Kindle from [Legimi](https://www.legimi.pl/).

It is completely unofficial. I created it to be able to download ebooks from my shelf on operating systems not supported by official app (Linux, mostly).
I created it based on the traffic exchanged between official Legimi application and server.
As such, it does not support many message types, errors and features and probably doesn't handle them well - use at your own risk.
It only allows to download a book that is on the user's shelf.

## Dependencies
- Lua 5.3+ (may work with Lua 5.2 also, but it was not tested)
- http
- argparse

### Installation

```bash
luarocks --lua-version <your_lua_version, e.g. 5.4> --tree .luarocks install http
luarocks --lua-version <your_lua_version, e.g. 5.4> --tree .luarocks install argparse
```

## Usage

First you need to install dependencies as described above. Then you need to obtain Device ID associated with your Kindle
and save it to `deviceid` file. Your Kindle should probably be activated first using official Legimi application.
Easiest way to get Device ID is to use script's `deviceid` command and pass your Kindle's serial no. (on your Kindle, go
to Settings -> Device Options -> Device Info). First set environment variables `LEGIMI_LOGIN` and `LEGIMI_PASS` with your
credentials, then invoke:

```bash
lua legimi deviceid G000PP12345678XX
```

Device ID will be stored automatically to `deviceid` file. Obtaining Device ID should be one-time action.

Once you have your Device ID, you may start downloading books that are on your shelf. To download a book, you have to pass
it's id number. Book's id number can be copied from book's page url or you can print a list books that are on your shelf
using `list` command (remember to set login and password variables):

```bash
lua legimi list
```

Once you have book id, you can use it to download an ebook file:

```bash
lua download <id>
```

You can pass multiple book ids to download.

Downloaded book files are saved within script's directory using following format: `<bookid>.mobi`. You can copy them directly
to your Kindle via USB.

## Development

Written with TDD (serialization part, at least) using LuaUnit

### Dependencies
- LuaUnit
- luacov

### Installation

```bash
luarocks --lua-version 5.4 --tree .luarocks install luaunit
luarocks --lua-version 5.4 --tree .luarocks install luacov
```

### Running tests

```bash
lua -e 'require"setup"' {-lluacov} test/suite/all.lua
```
`-lluacov` is optional for gathering coverage stats

#### Live tests

Tests in `test/suite/live.lua` are actually connecting to Legimi service. You need to set real data in `test/data/init.lua`
before running this suite.
