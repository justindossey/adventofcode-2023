-- Advent of Code day 17 part 2
local inspect = require("inspect")
-- https://github.com/Shakadak/lua-astar
local aStar = require("lua-astar/AStar")

local input_file = "input.txt"
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

local function parseInput(input)
	local parsed = {}
	for row, line in ipairs(input) do
		local chars = {}
		for col = 1, #line do
			local char = line:sub(col, col)
			table.insert(chars, tonumber(char))
		end
		table.insert(parsed, chars)
	end
	return parsed
end
local grid = parseInput(readFile(input_file))
local max_streak = 10
local min_streak = 4
local grid_height = #grid
local grid_width = #grid[1]

-- convert a y, x, direction, streak into a string key.
-- e.g. y, x, "N", 1 -> "1,1,N,1"
-- I tested memoizing this function, but it didn't seem to help.
local function key(y, x, dir, streak)
	return string.format("%d,%d,%s,%d", y, x, dir, streak)
end

-- split up my y, x, direction, streak key into a table.
-- Caching saves me about 1 second (from about 14.5 to 13.5) on my machine.
local key_to_table_cache = {}
local function unpack_key(str)
	if key_to_table_cache[str] then
		return key_to_table_cache[str]
	end
	local y, x, dir, streak = str:match("(%d+),(%d+),(%a),(%d+)")
	local t = { y = tonumber(y), x = tonumber(x), dir = dir, streak = tonumber(streak) }
	key_to_table_cache[str] = t
	return t
end

-- return the neighbors of a node.
-- This is also memoized-- this saves about 20% of the time.
local node_cache = {}
local function expand(node)
	if node_cache[node] then
		return node_cache[node]
	end

	-- figure out where we are. The node key will be y, x, direction, streak
	local node_data = unpack_key(node)
	local neighbors = {}
	local longer_streak = node_data.streak + 1
	local fresh_streak = 1
	-- if I got here going north, I can go north, east, or west, unless my streak
	-- is 3 or I am at the top of the grid.
	if node_data.dir == "N" then
		-- if we are going north, we can keep going north.
		if node_data.streak < max_streak and node_data.y > 1 then
			local up = key(node_data.y - 1, node_data.x, "N", longer_streak)
			table.insert(neighbors, up)
		end
		if node_data.x > 1 and node_data.streak >= min_streak then
			local left = key(node_data.y, node_data.x - 1, "W", fresh_streak)
			table.insert(neighbors, left)
		end
		if node_data.x < grid_width and node_data.streak >= min_streak then
			local right = key(node_data.y, node_data.x + 1, "E", fresh_streak)
			table.insert(neighbors, right)
		end
	elseif node_data.dir == "S" then
		if node_data.streak < max_streak and node_data.y < grid_height then
			local down = key(node_data.y + 1, node_data.x, "S", longer_streak)
			table.insert(neighbors, down)
		end
		if node_data.x > 1 and node_data.streak >= min_streak then
			local left = key(node_data.y, node_data.x - 1, "W", fresh_streak)
			table.insert(neighbors, left)
		end
		if node_data.x < grid_width and node_data.streak >= min_streak then
			local right = key(node_data.y, node_data.x + 1, "E", fresh_streak)
			table.insert(neighbors, right)
		end
	elseif node_data.dir == "W" then
		if node_data.streak < max_streak and node_data.x > 1 then
			local left = key(node_data.y, node_data.x - 1, "W", longer_streak)
			table.insert(neighbors, left)
		end
		if node_data.y > 1 and node_data.streak >= min_streak then
			local up = key(node_data.y - 1, node_data.x, "N", fresh_streak)
			table.insert(neighbors, up)
		end
		if node_data.y < grid_height and node_data.streak >= min_streak then
			local down = key(node_data.y + 1, node_data.x, "S", fresh_streak)
			table.insert(neighbors, down)
		end
	elseif node_data.dir == "E" then
		if node_data.streak < max_streak and node_data.x < grid_width then
			local right = key(node_data.y, node_data.x + 1, "E", longer_streak)
			table.insert(neighbors, right)
		end
		if node_data.y > 1 and node_data.streak >= min_streak then
			local up = key(node_data.y - 1, node_data.x, "N", fresh_streak)
			table.insert(neighbors, up)
		end
		if node_data.y < grid_height and node_data.streak >= min_streak then
			local down = key(node_data.y + 1, node_data.x, "S", fresh_streak)
			table.insert(neighbors, down)
		end
	end
	node_cache[node] = neighbors
	return neighbors
end

-- return the cost of traveling from one node to another.
local function cost(from)
	return function(to)
		local to_coords = unpack_key(to)
		-- weights are stored in the grid
		return grid[to_coords.y][to_coords.x]
	end
end

-- return an estimate of the cost to reach the goal from the given node.
-- 0 means we're just using Dijkstra's algorithm.
local function heuristic(node)
	return 0
end

-- return true if the given node is the goal. We have multiple goals because
-- we could have multiple streaks of 4 or more, and the streak count is encoded
-- in the node name.
local goal_strs = {}
for g = 4, max_streak do
	goal_strs[key(grid_height, grid_width, "S", g)] = true
	goal_strs[key(grid_height, grid_width, "E", g)] = true
end
local goal_reached = function(node)
	return goal_strs[node]
end

-- calculate the total cost of the path found
local function path_cost(path)
	if not path then
		return "No path found"
	end
	table.remove(path, 1) -- we don't count the loss from the first node
	local total = 0
	for _, node in ipairs(path) do
		local next_node = unpack_key(node)
		local weight = grid[next_node.y][next_node.x]
		total = total + weight
	end
	return total
end

local simpleAStar = aStar(expand)(cost)(heuristic)

logd("Checking entry going east")
local east_path = simpleAStar(goal_reached)(key(1, 1, "E", 1))
local east_cost = path_cost(east_path)
logd("East cost: " .. east_cost)

logd("Checking entry going south")
local south_path = simpleAStar(goal_reached)(key(1, 1, "S", 1))
local south_cost = path_cost(south_path)
logd("South cost: " .. south_cost)

local min_cost = math.min(east_cost, south_cost)
print("Part 2 answer: " .. min_cost)
