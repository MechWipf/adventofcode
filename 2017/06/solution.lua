package.path = [[X:\Notizen\OtherStuff\?.lua;]] .. package.path
local utils = require "utils"


print( (function () return table.unpack { 1, 2 }, 3 end)() );