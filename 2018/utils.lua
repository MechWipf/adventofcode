---
-- Some usefull functions
-- @module utils
local utils = {}

--- Serializes a table.
-- @tparam table t
-- @tparam[opt=true] bool closed functional table?
-- @treturn string serialized table
function utils.serialize ( t, closed )
  if closed == nil then closed = true end
  local string_builder = {}
  local parent_table = { [t] = false }
  local tabs = 0
  local key = nil

  if closed then
    tabs = 1
    string_builder[#string_builder+1] = ( "{" )
  end

  while next( t, key ) do
    local value, data
    key, value = next( t, key )

    if type(key) == "number" then
      data = ("%s[%s] = "):format( ("\t"):rep( tabs ), key )
    else
      data = ("%s[%q] = "):format( ("\t"):rep( tabs ), tostring( key ) )
    end

    local _type = type(value)
    if _type == "table" and parent_table[value] == nil then
      string_builder[#string_builder+1] = ( data .. "{ " )
      parent_table[value] = { t, tabs, key }
      t, tabs, key = value, tabs + 1, nil
    elseif _type == "number" then
      string_builder[#string_builder+1] = ( ("%s%s,"):format( data, value ) )
    else
      string_builder[#string_builder+1] = ( ("%s%q,"):format( data, tostring( value ) ) )
    end

    while next( t, key ) == nil and parent_table[t] do
      t, tabs, key = table.unpack( parent_table[t] )
      string_builder[#string_builder+1] = ( ("\t"):rep( tabs ) .. "}," )
    end
  end

  if closed then
    string_builder[#string_builder+1] = ( "}" )
  end

  return table.concat( string_builder, "\n" )
end

--- Serializes and prints a table
-- @tparam table t
function utils.printTable( t )
  print( utils.serialize( t, false ) )
end

--- Shortcut for os.run without env
-- @tparam string path to file
-- @param[opt] ... arguments to pass to the file
function utils.run ( path, ... )
  os.run( {}, path, ... )
end

--- Decodes a nbt table to a more readable lua table
-- @tparam table t in table
-- @treturn table out table
function utils.nbtToTable ( t )
  if not t then return end

  local out = {}
  local tagType = t.type

  if tagType == "NBTTagCompound" then
    for _, v in pairs( t.keys ) do
      out[v] = utils.nbtToTable( t.value[v] )
    end
  elseif tagType == "NBTTagList" then
    for _, v in pairs( t.value ) do
      out[ #out + 1 ] = utils.nbtToTable( v )
    end
  elseif tagType:match( "NBTTag.+" ) then
    return t.value
  end

  return out
end

--- Converts a UUID into id and meta
-- @tparam number uuid number to convert
-- @treturn[1] int id
-- @treturn[1] int meta
function utils.getID(uuid)
  local meta
  local id

  if uuid > 32768 then
    meta = uuid % 32768
    id = uuid - meta * 32768
  else
    id = uuid
    meta = 0
  end

  return id, meta
end

--- Converts id and meta into a UUID
-- @tparam int id
-- @tparam int meta
-- @treturn int uuid
function utils.getUUID( id, meta )
  return id + meta * 32768
end

local math = math
--- Addition to the math library
-- @tparam number n
-- @tparam number min
-- @tparam number max
-- @treturn bool is n in range of min and max?
function math.inRange( n, min, max )
  return n <= max and n >= min
end

--- Addition to the math library
-- @tparam number n
-- @tparam number min
-- @tparam number max
function math.clamp ( n, min, max )
  if n > max then return max end
  if n < min then return min end

  return n
end

--- Addition to the math library
-- @tparam table points list of points: `{{x,y},...}`
function math.linearRegression ( points )
  local n = #points

  local xsum  = 0
  local x2sum = 0
  local ysum  = 0
  local xysum = 0

  for i = 1, n, 1 do
    xsum  = xsum  + points[i][1]
    ysum  = ysum  + points[i][2]
    x2sum = x2sum + points[i][1]^2
    xysum = xysum + points[i][1] * points[i][2]
  end

  local a = ( n * xysum - xsum * ysum ) / ( n * x2sum - xsum^2 )
  local b = ( x2sum * ysum - xsum*xysum ) / ( x2sum * n - xsum^2 )

  return a, b
end

function utils.format ( a, b )
  if type( b ) == "table" then
    for k, _ in pairs( b ) do b[k] = tostring( b[k] )  end
    return a:format( table.unpack( b ) )
  end

  return a:format( tostring( b ) )
end

function utils.gsplit(s,sep)
	local lasti, done, g = 1, false, s:gmatch('(.-)'..sep..'()')
	return function()
		if done then return end
		local v,i = g()
		if s == '' or sep == '' then done = true return s end
		if v == nil then done = true return s:sub(lasti) end
		lasti = i
		return v
	end
end

function utils.fileRead ( path )
  local f = io.open( path, "r" )
  if not f then error "File not found" end
  local content = f:read "*a" f:close()
  return content
end

function utils.fileWrite( path, content )
  local f = io.open( path, "w" )
  f:write( content )
  f:close()
end

function utils.fileWriteStream( path, callback )
  local f = io.open( path, "w" )
  while true do
    local content = callback()
    if content == false then break end
    f:write( content )
  end
  f:close()
end

function utils.binaryRead ( path )
  local f = io.open( path, "rb" )
  if not f then error "File not found" end
  local content = {}
  local b = f:read()
  while b do
    content[#content+1] = b
    b = f:read()
  end
  return content
end

function utils.binaryWrite ( path, content )
  local f = io.open( path, "wb" )
  for _, b in pairs( content ) do
    f:write( b )
  end
  f:close()
end

function utils.reduceNum ( x, t, s )
  t = t or { " ", "k", "M", "G", "T", "P", "E", "Z", "Y" }
  s = s or 1000

  local i = 1
  while x > s^2 do
    x = x / s
    i = i + 1
  end

  return x, t[i]
end

function utils.reduceNumX ( x, t )
  if not t or not x then error "null argument" end

  local i = 1
  while t[i+1] and math.abs(x) > t[i+1][2]*2 or false do
    x = x / t[i+1][2]
    i = i + 1
  end

  return x, t[i][1]
end

function utils.toHex ( str )
  local s = str:gsub( ".", function (c)
    return string.format( "%02x", c:byte() )
  end )
  return s
end

function utils.fromHex ( str )
  local s = str:gsub( "..", function (c)
    return string.char( tonumber( c, 16 ) )
  end )
  return s
end

function utils.loadHex ( str )
  str = utils.fromHex( str )

  return loadstring( str )
end

function utils.gsplit(s,sep)
	local lasti, done, g = 1, false, s:gmatch('(.-)'..sep..'()')
	return function()
		if done then return end
		local v,i = g()
		if s == '' or sep == '' then done = true return s end
		if v == nil then done = true return s:sub(lasti) end
		lasti = i
		return v
	end
end

function utils.explode ( s, sep )
  local r = {}
  for p in utils.gsplit( s, sep ) do
    r[#r+1] = p
  end
  return r
end

function _G.table:foreach ( callback )
  local k, v = next( self )
  while k do
    callback( k, v )

    k,v = next( self )
  end
end

local function deep ( self, path, write )
  local parent = nil
  local t = self

  local _part
  for part in utils.gsplit( path:gsub("^%.", ""), "%." ) do
    _part = part
    local newT = t[part]

    if not newT and not write then
      return nil
    elseif write then
      t[part] = {}
      newT = t[part]
    end

    parent, t = t, newT
  end

  if write then
    return t, parent, _part
  else
    return t
  end
end

function _G.table.deep ( self, path )
  return deep( self, path, false )
end

function _G.table.deepWrite ( self, path, value )
  local _, t, part = deep( self, path, true )
  t[part] = value
end

function utils.trace ( fn, ... )
  local args = {...}
  local sb = {}
  local ret = xpcall(function() return fn(table.unpack(args)) end, function(err)
    local trace = {}
    local i, hitEnd, _, e = 4, false
    repeat
      _, e = pcall(function() error("<tracemarker>", i) end)
      i = i + 1
      if e == "xpcall: <tracemarker>" then
        hitEnd = true
        break
      end
      table.insert(trace, e)
    until i > 10
    table.remove(trace)
    if err:match("^" .. trace[1]:match("^(.-:%d+)")) then table.remove(trace, 1) end
    sb[#sb+1] = ("\nProgram has crashed! Stack trace:")
    sb[#sb+1] = (err)
    for i, v in ipairs(trace) do
      sb[#sb+1] = ("  at " .. v:match("^(.-:%d+)"))
    end
    if not hitEnd then
      sb[#sb+1] = ("  ...")
    end
  end)

  return ret, table.concat( sb, "\n" )
end

return utils