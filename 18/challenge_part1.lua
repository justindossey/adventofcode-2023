-- Advent of Code day 18 part 1
local inspect = require("inspect")

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
    -- lines look like "R 8 (#hexcode)" but we don't need the color right now
    local direction, distance = line:match("^([RLUD])%s+(%d+)")
    table.insert(parsed, {direction = direction, distance = tonumber(distance)})
  end
  return parsed
end

-- return the manhattan distance between two points
local function manhattanDistance(point1, point2)
  return math.abs(point1.x - point2.x) + math.abs(point1.y - point2.y)
end

-- print a grid showing the path
local function printGrid(intervals)
  local grid = {}
  local max_x = 0
  local min_x = 0
  local min_y = 0
  local max_y = 0
  local out = ""
  for _, interval in ipairs(intervals) do
    max_x = math.max(max_x, interval.start.x, interval.finish.x)
    min_x = math.min(min_x, interval.start.x, interval.finish.x)
    for x = math.min(interval.start.x, interval.finish.x),
            math.max(interval.start.x, interval.finish.x) do
      max_y = math.max(max_y, interval.start.y, interval.finish.y)
      min_y = math.min(min_y, interval.start.y, interval.finish.y)
      for y = math.min(interval.start.y, interval.finish.y),
              math.max(interval.start.y, interval.finish.y) do
        if not grid[y] then
          grid[y] = {}
        end
        grid[y][x] = "#"
      end
    end
  end
  for y = min_y, #grid do
    for x = min_x, max_x do
      if grid[y] and not grid[y][x] then
        grid[y][x] = "."
      end
    end
  end
  -- flood fill the 2D grid, replacing all the "." bounded by "#" with "#"
  local function floodFill(x, y)
    if grid[y] and grid[y][x] == "." then
      grid[y][x] = "#"
      floodFill(x + 1, y)
      floodFill(x - 1, y)
      floodFill(x, y + 1)
      floodFill(x, y - 1)
    end
  end
  floodFill(2, 2) -- arbitrary point inside the walls
  -- construct a string based on the grid
  for y = min_y, max_y do
    for x = min_x, max_x do
      out = out .. (grid[y][x] or ".")
    end
    out = out .. "\n"
  end
  return out
end

local dig_plan = parseInput(readFile(input_file))
local covered_intervals = {}
local start_points = {}
local start_point = {x = 1, y = 1}

-- work through the dig plan and record the covered intervals
while next(dig_plan) do
  local instruction = table.remove(dig_plan, 1)
  local direction = instruction.direction
  local distance = instruction.distance
  local end_point = {x = start_point.x, y = start_point.y}
  if direction == "R" then
    end_point.x = end_point.x + distance
  elseif direction == "L" then
    end_point.x = end_point.x - distance
  elseif direction == "U" then
    end_point.y = end_point.y - distance
  elseif direction == "D" then
    end_point.y = end_point.y + distance
  end
  table.insert(covered_intervals, {start = start_point, finish = end_point})
  table.insert(start_points, start_point)
  start_point = end_point
end
-- count the total distance covered
local total_distance = 0
for _, interval in ipairs(covered_intervals) do
  total_distance = total_distance + manhattanDistance(interval.start, interval.finish)
end
-- logd(inspect(start_points))
local filled_grid = printGrid(covered_intervals)
-- count all the "#" characters in the filled grid
local total_area = 0
for char in filled_grid:gmatch("#") do
  total_area = total_area + 1
end
logd("Total distance covered: " .. total_distance)
print("Area of polygon: " .. total_area)
