local Days = {
    DayOne = require "solution.day_one",
    DayTwo = require "solution.day_two",
}


local meta_string = getmetatable("")

meta_string.__index = function ( self, idx )
    if (string[idx]) then
        return string[idx]
    elseif ( tonumber( idx ) ) then
        return self:sub( idx, idx )
    else
        error("attempt to index a string value with bad key ('" .. tostring( idx ) .. "' is not part of the string library)", 2)
    end
end

meta_string.__mul = function ( self, num)
    return string.rep(self, num)
end

meta_string.__mod = function ( self, arg)
    if ( type( arg ) == "string" ) then
        return string.format( self, arg )
    else
        return string.format( self, unpack( arg ) )
    end
end

local function main ()
    for _, m in pairs( Days ) do
        for name, solution in pairs ( m.active ) do
            if solution == true then
                print "-----------"
                m[name]()
                print "-----------"
            end
        end
    end
end

main()