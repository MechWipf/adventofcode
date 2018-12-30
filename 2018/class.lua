-- ****************************** --
-- User: MechWipf
-- Date: 27.06.2015
-- Time: 17:12
-- ****************************** --

local module = {}

function module.class(className)
    return function(prototype)
        
        local metatable = { __index = prototype }
        prototype.__metatable = metatable

        local funName = "Create" .. className
        module[funName] = function(...)
            local self = setmetatable({}, metatable)
            if self.__construct then self:__construct(...) end
            return self
        end
    end
end

return module