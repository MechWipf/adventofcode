local utils = dofile [[x:\Notizen\OtherStuff\utils.lua]]

local function main ( instructions, alt )
    local iPointer = 1
    local step = 0

    while instructions[iPointer] do
        local jmpCount = tonumber(instructions[iPointer])

        if jmpCount >= 3 and alt then
            instructions[iPointer] = instructions[iPointer] - 1
        else
            instructions[iPointer] = instructions[iPointer] + 1
        end

        iPointer = iPointer + jmpCount
        step = step + 1
    end

    print(step)
end

local f = io.open [[X:\Notizen\OtherStuff\advent\05\input.txt]]
local instructions = f:read "*a":explode "\n" f:close()
main(instructions)
