package.path = arg[1] .. "?.lua;" .. package.path
local utils = require "libs.utils"

local function getTowers ( raw )
  local n = raw:find "->"
  return
    n and raw:sub( n + 3, 1e9 ):gsub(" ",""):explode "," or nil,
    raw:match( [[^([a-z]*).%(([0-9]*)%)]] )
end

local function getWeight( tower, tree, childs, weight )
  local w = weight[tower]

  if childs[tower] then
    for _, t in pairs(childs[tower]) do
      w = w + getWeight( t, tree, childs, weight )
    end
  end

  return w
end

local function main ( lines )
  local tree = {}
  local childs = {}
  local weight = {}

  for line in lines do
    local subTowers, baseTower, baseTowerWeight = getTowers( line )
    weight[baseTower] = baseTowerWeight

    if subTowers then
      childs[baseTower] = subTowers
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

  do
    local last = last
    local stack = { last }
    local done = false

    while not done do
      local dif = {}

      for _, tower in pairs( childs[last] ) do
        local w = getWeight(tower, tree, childs, weight)
        if not dif[w] then
          dif[w] = { t = tower, c = 1 }
        else
          dif[w].c = dif[w].c + 1
        end

        print(tower, w)
      end

      for _, v in pairs(dif) do
        if v.c == 1 then
          last = v.t
          if not childs[last] then done = true print( last, "no more childs" ) end
          break
        end
      end

      local allEqual = true
      local _k, _v
      for k,v in pairs(dif) do
        if _k then
          print("cmp", v.t .. ":" .. k, _v.t .. ":" .. _k)
          if not _k == k then allEqual = false break end
        end
        local _k, _v = k, v
      end

      done = allEqual

    end
  end
end

main( io.lines "input.txt" )