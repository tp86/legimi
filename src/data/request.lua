local class = require "class"
local init = class.constructor

local Auth = class {
  [init] = function() end,
}

return {
  Auth = Auth,
}
