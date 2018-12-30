-- Global Vars
local io = require "io"
local utils = require "utils"
local classEnv = require "class"
local class = classEnv.class
local inputPath = "input/day003/input.txt"
--

local module = { active = {} }

--[[
    --- Day 3: No Matter How You Slice It ---

    The Elves managed to locate the chimney-squeeze prototype fabric for Santa's suit (thanks to someone who helpfully wrote its box IDs on the wall of the warehouse in the middle of the night). Unfortunately, anomalies are still affecting them - nobody can even agree on how to cut the fabric.

    The whole piece of fabric they're working on is a very large square - at least 1000 inches on each side.

    Each Elf has made a claim about which area of fabric would be ideal for Santa's suit. All claims have an ID and consist of a single rectangle with edges parallel to the edges of the fabric. Each claim's rectangle is defined as follows:

        The number of inches between the left edge of the fabric and the left edge of the rectangle.
        The number of inches between the top edge of the fabric and the top edge of the rectangle.
        The width of the rectangle in inches.
        The height of the rectangle in inches.

    A claim like #123 @ 3,2: 5x4 means that claim ID 123 specifies a rectangle 3 inches from the left edge, 2 inches from the top edge, 5 inches wide, and 4 inches tall. Visually, it claims the square inches of fabric represented by # (and ignores the square inches of fabric represented by .) in the diagram below:

    ...........
    ...........
    ...#####...
    ...#####...
    ...#####...
    ...#####...
    ...........
    ...........
    ...........

    The problem is that many of the claims overlap, causing two or more claims to cover part of the same areas. For example, consider the following claims:

    #1 @ 1,3: 4x4
    #2 @ 3,1: 4x4
    #3 @ 5,5: 2x2

    Visually, these claim the following areas:

    ........
    ...2222.
    ...2222.
    .11XX22.
    .11XX22.
    .111133.
    .111133.
    ........

    The four square inches marked with X are claimed by both 1 and 2. (Claim 3, while adjacent to the others, does not overlap either of them.)

    If the Elves all proceed with their own plans, none of them will have enough fabric. How many square inches of fabric are within two or more claims?
]]--
module.active.sol1 = true

class "Area" {
    w_max = 1024,
    h_max = 1024,
    icons = {
        ["Claimed"] = "⚪",
        ["Empty"]   = "⚫",
        ["Overlap"] = "🔸",
    },

    __construct = function ( self )
        self.claims = {}
        self.cells = {}
        self.w = 0
        self.h = 0
    end,

    claim = function ( self, id, x, y, w, h )
        if ( (x + w) > self.w ) then self.w = x + w end
        if ( (y + h) > self.h ) then self.h = y + h end

        for posX = x, x + w - 1, 1 do
            for posY = y, y + h - 1, 1 do
                local idx = posX + posY * self.w_max

                if self.cells[idx] then
                    local cell = self.cells[idx]
                    table.insert( cell , id )

                    for i, claimId in pairs( cell ) do self.claims[claimId] = false end
                else
                    self.cells[idx] = { id }
                    if self.claims[id] == nil then
                        self.claims[id] = true
                    end
                end
            end
        end
    end,

    getSize = function ( self )
        return self.w, self.h
    end,

    printArea = function ( self, doPrint )
        doPrint = doPrint == nil and true or doPrint
        local overlapping = 0

        if doPrint then
            for y = 0, self.h + 1, 1 do
                local line = {}

                for x = 0, self.w + 1, 1 do
                    local idx = x + y * self.w_max
                    local value = self.cells[idx] 
                    local icon = nil

                    if value == nil then
                        icon = self.icons.Empty
                    elseif #value > 1 then
                        icon = self.icons.Overlap
                        overlapping = overlapping + 1
                    elseif #value == 1 then
                        icon = self.icons.Claimed
                    else
                        error "Unknown status."
                    end

                    table.insert( line, icon )
                end

                print( table.concat( line, "" ) )
            end
        else
            for i, v in pairs( self.cells ) do
                if v and #v > 1 then
                    overlapping = overlapping + 1
                end
            end
        end

        print( self.icons.Overlap, overlapping )

        for k,v in pairs( self.claims ) do
            if v then print("👍", k) end
        end
    end,
}

function module.sol1 ()
    local currentArea = classEnv.CreateArea()
    currentArea:claim( 1, 3, 2, 5, 4 )
    currentArea:printArea()
    print "----"
    
    currentArea = classEnv.CreateArea()
    currentArea:claim( 1, 1, 3, 4, 4 )
    currentArea:claim( 2, 3, 1, 4, 4 )
    currentArea:claim( 3, 5, 5, 2, 2 )
    currentArea:printArea()
    print "----"

    currentArea = classEnv.CreateArea()

    for line in io.lines( inputPath ) do
        line:gsub( "#([0-9]*) @ ([0-9]*),([0-9]*): ([0-9]*)x([0-9]*)", function ( ... ) currentArea:claim( ... ) end )
    end

    currentArea:printArea( false )
end

--[[
    --- Part Two ---

    Amidst the chaos, you notice that exactly one claim doesn't overlap by even a single square inch of fabric with any other claim. If you can somehow draw attention to it, maybe the Elves will be able to make Santa's suit after all!

    For example, in the claims above, only claim 3 is intact after all claims are made.

    What is the ID of the only claim that doesn't overlap?
]]--

return module