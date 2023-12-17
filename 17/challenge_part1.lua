-- Advent of Code day 17 part 1
local inspect = require("inspect")
-- https://github.com/Shakadak/lua-astar
local aStar = require("lua-astar/AStar")

local input_file = "input.txt"
-- debug function
local debug = false
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

local function parseInput(input)
  local parsed = {}
  for row, line in ipairs(input) do
    local chars = {}
    for col=1, #line do
      local char = line:sub(col,col)
      table.insert(chars, tonumber(char))
    end
    table.insert(parsed, chars)
  end
  return parsed
end
local grid = parseInput(readFile(input_file))

-- convert a y, x, direction, streak into a string key.
-- e.g. y, x, "N", 1 -> "1,1,N,1"
local function key(y, x, dir, streak)
  return tostring(y) .. "," .. tostring(x) .. "," .. dir .. "," .. tostring(streak)
end

-- split up my y, x, weight key into a table.
local function unpack_key(str)
  local y, x, dir, streak = str:match("(%d+),(%d+),(%a),(%d)")
  return {y=tonumber(y), x=tonumber(x), dir=dir, streak=tonumber(streak)}
end

-- return the neighbors of a node.
local function expand(node)
  -- figure out where we are. The node key will be y, x, direction, streak
  local node_data = unpack_key(node)
  local neighbors = {}
  local longer_streak = node_data.streak + 1
  local fresh_streak = 1
  -- if I got here going north, I can go north, east, or west, unless my streak
  -- is 3 or I am at the top of the grid.
  if node_data.dir == "N" then
    -- if we are going north, we can keep going north.
    if node_data.streak < 3 and node_data.y > 1 then
      local up = key(node_data.y-1, node_data.x, "N", longer_streak)
      table.insert(neighbors, up)
    end
    if node_data.x > 1 then
      local left = key(node_data.y, node_data.x-1, "W", fresh_streak)
      table.insert(neighbors, left)
    end
    if node_data.x < #grid[1] then
      local right = key(node_data.y, node_data.x+1, "E", fresh_streak)
      table.insert(neighbors, right)
    end
  elseif node_data.dir == "S" then
    if node_data.streak < 3 and node_data.y < #grid then
      local down = key(node_data.y+1, node_data.x, "S", longer_streak)
      table.insert(neighbors, down)
    end
    if node_data.x > 1 then
      local left = key(node_data.y, node_data.x-1, "W", fresh_streak)
      table.insert(neighbors, left)
    end
    if node_data.x < #grid[1] then
      local right = key(node_data.y, node_data.x+1, "E", fresh_streak)
      table.insert(neighbors, right)
    end
  elseif node_data.dir == "W" then
    if node_data.streak < 3 and node_data.x > 1 then
      local left = key(node_data.y, node_data.x-1, "W", longer_streak)
      table.insert(neighbors, left)
    end
    if node_data.y > 1 then
      local up = key(node_data.y-1, node_data.x, "N", fresh_streak)
      table.insert(neighbors, up)
    end
    if node_data.y < #grid then
      local down = key(node_data.y+1, node_data.x, "S", fresh_streak)
      table.insert(neighbors, down)
    end
  elseif node_data.dir == "E" then
    if node_data.streak < 3 and node_data.x < #grid[1] then
      local right = key(node_data.y, node_data.x+1, "E", longer_streak)
      table.insert(neighbors, right)
    end
    if node_data.y > 1 then
      local up = key(node_data.y-1, node_data.x, "N", fresh_streak)
      table.insert(neighbors, up)
    end
    if node_data.y < #grid then
      local down = key(node_data.y+1, node_data.x, "S", fresh_streak)
      table.insert(neighbors, down)
    end
  end
  return neighbors
end

-- return the cost of traveling from one node to another.
local function cost(from)
  return function(to)
    local to_coords = unpack_key(to)
    return grid[to_coords.y][to_coords.x]
  end
end

-- return an estimate of the cost to reach the goal from the given node.
local function heuristic(node)
  return 0
end

-- return true if the given node is the goal.
local goal_strs = {}
for g=1,3 do
  goal_strs[key(#grid, #grid[1], "S", g)] = true
  goal_strs[key(#grid, #grid[1], "E", g)] = true
end
local goal_reached = function(node)
  return goal_strs[node]
end

-- convert the path to a string.
local function pathToString(path)
  if not path then
    return "No path found"
  end
  local str = table.remove(path, 1)
  for _, node in ipairs(path) do
    str = str .. " -> " .. node
  end
  return str
end

-- calculate the total cost of the path found
local function path_cost(path)
  if not path then
    return "No path found"
  end
  local cur_node = unpack_key(table.remove(path, 1))
  local total = grid[cur_node.y][cur_node.x]
  for _, node in ipairs(path) do
    local next_node = unpack_key(node)
    local weight = grid[next_node.y][next_node.x]
    total = total + weight
  end
  return total
end

local simpleAStar = aStar(expand)(cost)(heuristic)
local path = simpleAStar(goal_reached)(key(1, 1, "E", 1))

logd(pathToString(path))
print("Part 1 answer: " .. path_cost(path))
