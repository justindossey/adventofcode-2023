-- Advent of Code day 23 part 1
local inspect = require("inspect")
local astar = require("lua-astar/AStar")

local input_file = "example1.txt"
-- debug function
local debug = true
local function logd(...)
	if debug then
		print(...)
	end
end

local function readFile(filename)
	local file = io.open(filename, "r")
	if not file then
		print("Error opening the file.")
		return
	end

	local lines = {}
	-- Iterate over each line in the file and append it to the table
	for line in file:lines() do
		table.insert(lines, line)
	end

	-- Close the file
	file:close()
	return lines
end

local function unpack_key(str)
  local y, x, dir = str:match("(%d+),(%d+),(.)")
  return tonumber(y), tonumber(x), dir
end

local function pack_key(y, x, dir)
  return string.format("%d,%d,%s", y, x, dir)
end

local lines
local function cost(from)
  return function(to)
    return -1
  end
end

local goal

local function heuristic(node)
  return 0
end


local function expand(node)
  local y, x, dir = unpack_key(node)
  local nodes = {}
  local current = lines[y]:sub(x, x)
  local right = lines[y]:sub(x+1, x+1)
  local left = lines[y]:sub(x-1, x-1)
  local up = lines[y-1] and lines[y-1]:sub(x, x)
  local down = lines[y+1] and lines[y+1]:sub(x, x)
  logd("At ("..y..","..x.."):","left", left, "right", right, "up", up, "down", down)
  if current == ">" and right ~= "" then
    logd("Must go right")
    table.insert(nodes, pack_key(y, x+1, dir))
  elseif current == "<" and left ~= "" then
    logd("Must go left")
    table.insert(nodes, pack_key(y, x-1, dir))
  elseif current == "v" and down ~= "" then
    logd("Must go down")
    table.insert(nodes, pack_key(y+1, x, dir))
  elseif current == "^" and up ~= "" then
    logd("Must go up")
    table.insert(nodes, pack_key(y-1, x, dir))
  end
  if next(nodes) then
    return nodes
  end
  -- if I don't have to go straight, check other options
  if lines[y] and (right == "." or right == ">") then
    dir = right == "." and dir or ">"
    logd("right", y, x, dir)
    table.insert(nodes, pack_key(y, x+1, dir))
  end
  if lines[y] and (left == "." or left == "<") then
    dir = left == "." and dir or "<"
    logd("left", y, x, dir)
    table.insert(nodes, pack_key(y, x-1, dir))
  end
  if lines[y+1] and (down == "." or down == "v") then
    dir = down == "." and dir or "v"
    logd("down", y, x, dir)
    table.insert(nodes, pack_key(y+1, x, dir))
  end
  if lines[y-1] and (up == "." or up == "^") then
    dir = up == "." and dir or "^"
    logd("up", y, x, dir)
    table.insert(nodes, pack_key(y-1, x, dir))
  end
  return nodes
end

local goal_reached = function(node)
  return node == goal
end

local function pathToString(path)
  if path == nil then
    return "No path found"
  else
    local ret = table.remove(path, 1)
    for _, n in ipairs(path) do
      ret = ret .. " → " .. n
    end
    return ret
  end
end

-- copy a table
local function copy(t)
  local ret = {}
  for k, v in pairs(t) do
    ret[k] = v
  end
  return ret
end

local function pathToGrid(path)
  local grid = copy(lines)
  if path == nil then return end
  for _, n in ipairs(path) do
    local y, x, _ = unpack_key(n)
    grid[y] = grid[y]:sub(1, x-1) .. "O" .. grid[y]:sub(x+1)
  end
  for _, line in ipairs(grid) do
    print(line)
  end
end

lines = readFile(input_file)
local start = pack_key(1, lines[1]:find("%."), "v")
goal = pack_key(#lines, lines[#lines]:find("%."), "v")
local simpleAStar = astar(expand)(cost)(heuristic)
local path = simpleAStar(goal_reached)(start)
print("Part 1 path: " .. pathToString(path))
pathToGrid(path)
print("Part 1 answer: " .. #path)
