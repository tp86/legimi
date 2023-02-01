local class = require "class"
local init = class.constructor

local Packet = class {
  [init] = function() end,
}

return {
  Packet = Packet,
}
