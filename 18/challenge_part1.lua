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
local function manhattan_distance(point1, point2)
  return math.abs(point1.x - point2.x) + math.abs(point1.y - point2.y)
end

local function calculate_area(vertices)
  local area = 0
  local perimeter = 0
  local j = #vertices
  for i = 1, #vertices do
    area = area + (vertices[j].x + vertices[i].x) * (vertices[j].y - vertices[i].y)
    perimeter = perimeter + manhattan_distance(vertices[j], vertices[i])
    j = i
  end
  return math.floor(math.abs(area / 2) + (perimeter / 2) + 1)
end

local dig_plan = parseInput(readFile(input_file))
local vertices = {}
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
  table.insert(vertices, start_point)
  start_point = end_point
end

print("Part 1 answer: " .. calculate_area(vertices))
