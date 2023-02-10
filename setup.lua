local version = string.match(_VERSION, "Lua ([%d%.]+)")

local function prependtopath(pathname, paths)
  table.insert(paths, package[pathname])
  package[pathname] = table.concat(paths, ";")
end

prependtopath("path", {
  "src/?.lua",
  "src/?/init.lua",
  "lib/?/src/?.lua",
  ".luarocks/share/lua/" .. version .. "/?.lua",
})

prependtopath("cpath", {
  ".luarocks/lib/lua/" .. version .. "/?.so",
})
