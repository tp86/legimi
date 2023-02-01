package.path = table.concat({
  "src/?.lua",
  "src/?/init.lua",
  "lib/?/src/?.lua",
  ".luarocks/share/lua/5.4/?.lua",
  package.path
}, ";")
