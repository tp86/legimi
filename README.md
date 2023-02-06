# legimi
Unofficial Legimi ebook downloader for Kindle

This is Legimi ebook downloader made for downloading ebooks for Kindle from [Legimi](https://www.legimi.pl/).

It is completely unofficial. I created it to be able to download ebooks from my shelf on operating systems not supported by official app (Linux, mostly).
I created it based on the traffic exchanged between official Legimi application and server.
As such, it does not support many message types, errors and features and probably doesn't handle them well - use at your own risk.
It only allows to download a book that is on the user's shelf.

## Dependencies
- http

### Installation

```bash
luarocks --lua-version 5.4 --tree .luarocks install http
```

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
lua -e 'require"setup"' {-lluacov} test/suite.lua
```
`-lluacov` is optional for gathering coverage stats
