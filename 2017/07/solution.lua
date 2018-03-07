package.path = [[D:\Workspace\Projects\adventofcode\libs\?.lua;]] .. package.path
local utils = require "utils"

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

  local printed = {}
  for k, tower in pairs( tree ) do
    if tree[tower] == last and not printed[tower] then
      printed[tower] = true
      print(tower, getWeight(tower, tree, childs, weight))
    end
  end
end

main( io.lines( select(1, ...) ) )