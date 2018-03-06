package.path = [[X:\Notizen\OtherStuff\?.lua;]] .. package.path
local utils = require "utils"

local function getTowers ( raw )
    local n = raw:find "->"
    return
        n and raw:sub( n + 3, 1e9 ):gsub(" ",""):explode "," or nil,
        raw:match( [[^([a-z]*).%(([0-9]*)%)]] )
end

local function main ( lines )
    local tree = {}
    local weight = {}

    for line in lines do
        local subTowers, baseTower, baseTowerWeight = getTowers( line )
        weight[baseTower] = baseTowerWeight

        if subTowers then
            for k, tower in pairs( subTowers ) do
                if tree[tower] then error "already exists" end
                tree[tower] = baseTower
            end
        end
    end

    local last = nil
    local m = next(tree)
    while m do
        last = m
        m = tree[m]
    end

    print(last)

    local printed = {}
    for k, tower in pairs( tree ) do
        if tree[tower] == last and not printed[tower] then
            printed[tower] = true
            print(tower, weight[tower])
        end
    end
end

main( io.lines( select(1, ...) ) )