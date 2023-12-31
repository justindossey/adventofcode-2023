-- Advent of Code day 21 part 1
local inspect = require("inspect")

local input_file = "input.txt"
local step_target = 64
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

local function Node(y, x)
  local self = { y = y, x = x, neighbors = {} }

  function self.touch()
    self.touched = true
  end

  function self.is_touched()
    return self.touched
  end

  function self.mark_start()
    self.start = true
  end

  function self.is_start()
    return self.start
  end

  return self
end
local garden_plots = {}

local function parse_input(lines)
  for i, line in ipairs(lines) do
    for j = 1, #line do
      local char = line:sub(j, j)
      if char == "." or char == "S" then
        if not garden_plots[i] then
          garden_plots[i] = {}
        end
        if not garden_plots[i][j] then
          garden_plots[i][j] = Node(i, j)
        end
        if char == "S" then
          garden_plots[i][j].mark_start()
        end
      end
    end
  end
end

local function link_neighbors()
  for i, row in pairs(garden_plots) do
    for j, plot in pairs(row) do
      if garden_plots[i - 1] and garden_plots[i - 1][j] then
        table.insert(plot.neighbors, garden_plots[i - 1][j])
      end
      if garden_plots[i + 1] and garden_plots[i + 1][j] then
        table.insert(plot.neighbors, garden_plots[i + 1][j])
      end
      if garden_plots[i][j - 1] then
        table.insert(plot.neighbors, garden_plots[i][j - 1])
      end
      if garden_plots[i][j + 1] then
        table.insert(plot.neighbors, garden_plots[i][j + 1])
      end
    end
  end
end

-- function to return the starting node in the graph
local function find_start()
  for i, row in pairs(garden_plots) do
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
local step_queue = {}
local function walk_graph(start_node, steps)
  -- table.insert(step_queue, {node=start_node, target=step_target})
  step_queue[1] = step_queue[1] or {}
  step_queue[1][start_node] = true
  for step=1, steps do
    logd(step)
    for node, _ in pairs(step_queue[step]) do
      step_queue[step][node] = nil
      logd(" Processing plot: "..node.y..", "..node.x)
      step_queue[step + 1] = step_queue[step + 1] or {}
      for i, neighbor in ipairs(node.neighbors) do
        step_queue[step+1][neighbor] = true
        logd("  Neighbor: "..neighbor.y..", "..neighbor.x)
      end
    end
  end
  local count = 0
  for j, _ in pairs(step_queue[steps + 1]) do
    count = count + 1
  end
  print("Queue size: "..count)
end

-- function to count the number of unique nodes in the step queue
local function count_unique_in_step_queue()
  local unique = {}
  for i, message in ipairs(step_queue) do
    local node = message.node
    if not unique[node] then
      unique[node] = true
    end
  end
  local count = 0
  for node, _ in pairs(unique) do
    count = count + 1
  end
  return count
end

parse_input(readFile(input_file))
link_neighbors()
walk_graph(find_start(), step_target)
-- print("Part 1 answer: "..count_unique_in_step_queue())
