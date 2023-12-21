-- Advent of Code day 21 part 1
local inspect = require("inspect")

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

local function Node(y, x)
  local self = { y = y, x = x, neighbors = {} }

  function self.touch(step_target)
    self.step_target = step_target
    self.touched = true
  end

  function self.get_step_target()
    return self.step_target or "."
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
local function walk_graph(current_plot, step_target)
  local steps = 0
  step_target = step_target or 64
  while steps <= step_target do
    logd("Step "..steps.." Processing plot: "..current_plot.y..", "..current_plot.x)
    logd(step_target .." steps remaining")
    current_plot.touch(step_target)
    steps = steps + 1
    for i, neighbor in ipairs(current_plot.neighbors) do
      logd("  Neighbor: "..neighbor.y..", "..neighbor.x)
      if not neighbor.is_touched() then
        logd("    Not touched, walking")
        walk_graph(neighbor, step_target - 1)
      end
    end
  end
end

-- function to count how many garden plots are touched
local function count_touched()
  local touched = 0
  for i, row in pairs(garden_plots) do
    for j, plot in pairs(row) do
      if plot.is_touched() and plot.get_step_target() % 2 == 0 then
        touched = touched + 1
      end
    end
  end
  return touched
end

-- function to print the grid.
local function print_grid(lines)
  for i=1,#lines do
    for j=1,#lines[i] do
      if garden_plots[i] and garden_plots[i][j] then
        io.write(garden_plots[i][j].get_step_target())
      else
        io.write(lines[i]:sub(j, j))
      end
    end
    print()
  end
end

local lines = readFile(input_file)
parse_input(lines)
link_neighbors()
walk_graph(find_start(), 6)
print_grid(lines)
print("Part 1 answer: "..count_touched())
