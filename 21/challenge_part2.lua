-- Advent of Code day 21 part 1
-- Thanks to HyperNeutrino's video explaining the problem,
-- here https://www.youtube.com/watch?v=9UOMZSL0JTg
-- Pretty much everything in "MAIN PROGRAM" section was inspired by that video
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

-- a little OOP, Lua style
local function Node(y, x)
	local self = { y = y, x = x, neighbors = {} }

	function self.mark_start()
		self.start = true
	end

	function self.is_start()
		return self.start
	end

	return self
end

-- input is just a table of strings, so this function turns that into a table
-- of Node objects (ignoring rocks which are "#")
local function parse_input(lines)
	local grid = {}
	for i, line in ipairs(lines) do
		for j = 1, #line do
			local char = line:sub(j, j)
			if char == "." or char == "S" then
				if not grid[i] then
					grid[i] = {}
				end
				if not grid[i][j] then
					grid[i][j] = Node(i, j) -- Node has coordinates but no neighbors yet
				end
				if char == "S" then
					grid[i][j].mark_start()
				end
			end
		end
	end
	return grid
end

-- this function connects the nodes in the graph to their neighbors
local function link_neighbors(nodes)
	for i, row in pairs(nodes) do
		for j, plot in pairs(row) do
			if nodes[i - 1] and nodes[i - 1][j] then
				table.insert(plot.neighbors, nodes[i - 1][j])
			end
			if nodes[i + 1] and nodes[i + 1][j] then
				table.insert(plot.neighbors, nodes[i + 1][j])
			end
			if nodes[i][j - 1] then
				table.insert(plot.neighbors, nodes[i][j - 1])
			end
			if nodes[i][j + 1] then
				table.insert(plot.neighbors, nodes[i][j + 1])
			end
		end
	end
end

-- function to return the starting node in the graph
local function find_start(graph)
	for i, row in pairs(graph) do
		for j, plot in pairs(row) do
			if plot.is_start() then
				return plot
			end
		end
	end
	print("Error: no starting node found")
end

-- function to walk the graph and count how many garden plots are touched in 64
-- steps
local function walk_graph(start_node, steps)
	local step_queue = { {} }
	step_queue[1][start_node] = true
	for step = 1, steps do
		for node, _ in pairs(step_queue[step]) do
			step_queue[step][node] = nil
			step_queue[step + 1] = step_queue[step + 1] or {}
			for i, neighbor in ipairs(node.neighbors) do
				step_queue[step + 1][neighbor] = true
			end
		end
	end
	-- count the number of nodes that we would visit in the last step
	local count = 0
	for j, _ in pairs(step_queue[steps + 1]) do
		count = count + 1
	end
	return count
end

-- MAIN PROGRAM
local lines = readFile(input_file)
local garden_plots = parse_input(lines)
link_neighbors(garden_plots)
local size = #lines
local steps = 26501365 -- from the challenge
-- this is the number of grids we would traverse in the given step count
local grid_width = math.floor(steps / size) - 1

-- how many plots will we cross, starting with an odd number of steps?
-- extra floor here to convert FP to integer
local odd = math.floor((math.floor(grid_width / 2) * 2 + 1) ^ 2)
-- how many plots will we cross, starting with an even number of steps?
local even = math.floor((math.floor((grid_width + 1) / 2) * 2) ^ 2)

-- keep track of the original starting node. We will be moving the start around
local start_node = find_start(garden_plots)
local original_start_node = start_node

-- FULL GRIDS
local odd_points = walk_graph(start_node, size * 2 + 1)
local even_points = walk_graph(start_node, size * 2)

-- CORNERS
start_node = garden_plots[#garden_plots][original_start_node.x]
local corner_steps = size - 1
local corner_t = walk_graph(start_node, corner_steps)
-- count steps from the left of the grid, same row as the S node
start_node = garden_plots[original_start_node.y][1]
local corner_r = walk_graph(start_node, corner_steps)
-- count steps from the right of the grid, same row as the S node
start_node = garden_plots[original_start_node.y][size]
local corner_l = walk_graph(start_node, corner_steps)
-- count steps from the top of the grid, same column as the S node
start_node = garden_plots[1][original_start_node.x]
local corner_b = walk_graph(start_node, corner_steps)

-- TRIANGLES
start_node = garden_plots[#garden_plots][1]
local small_steps = math.floor(size / 2) - 1
local large_steps = math.floor(size * 3 / 2) - 1
local small_tr = walk_graph(start_node, small_steps)
local large_tr = walk_graph(start_node, large_steps)
-- count the steps from the bottom right corner
start_node = garden_plots[#garden_plots][size]
local small_tl = walk_graph(start_node, small_steps)
local large_tl = walk_graph(start_node, large_steps)
-- count the steps from the top left corner
start_node = garden_plots[1][1]
local small_br = walk_graph(start_node, small_steps)
local large_br = walk_graph(start_node, large_steps)
-- count the steps from the top right corner
start_node = garden_plots[1][size]
local small_bl = walk_graph(start_node, small_steps)
local large_bl = walk_graph(start_node, large_steps)

local step_total = odd * odd_points
	+ even * even_points
	+ corner_t
	+ corner_r
	+ corner_l
	+ corner_b
	+ (grid_width + 1) * (small_tr + small_tl + small_br + small_bl)
	+ grid_width * (large_tr + large_tl + large_br + large_bl)
print("Part 2 answer: " .. step_total)
