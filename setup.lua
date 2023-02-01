local function prependtopath(pathname, paths)
  table.insert(paths, package[pathname])
  package[pathname] = table.concat(paths, ";")
end

prependtopath("path", {
  "src/?.lua",
  "src/?/init.lua",
  "lib/?/src/?.lua",
  ".luarocks/share/lua/5.4/?.lua",
})

prependtopath("cpath", {
  ".luarocks/lib/lua/5.4/?.so",
})
