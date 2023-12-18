-- Advent of Code day 18 part 2
-- local inspect = require("inspect")

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
  local directions = {"R","D","L","U"}
  for row, line in ipairs(input) do
    -- lines look like "R 8 (#hexcode)" and the hexcode is the instruction.
    -- The first five hex digits are the distance, and the last is the direction
    local distance, direction = line:match("%(#(%x+)(%x)%)")
    local instruction = { direction = directions[tonumber(direction, 16) + 1],
                          distance = tonumber(distance, 16) }
    table.insert(parsed, instruction)
  end
  return parsed
end

-- return the manhattan distance between two points
local function manhattan_distance(point1, point2)
  return math.abs(point1.x - point2.x) + math.abs(point1.y - point2.y)
end

-- calculate the area of a polygon, including the width of the lines (1 unit)
-- for example, a polygon with four vertices (1, 1), (1, 3), (3, 3), (3, 1)
-- should have area 9. A polygon with four vertices (1, 1), (1, 2), (2, 2), (2,
-- 1) would have area 4.
local function calculateArea(vertices)
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

-- process a single instruction
local function process_instruction(start_point, instruction)
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
  return end_point
end

local dig_plan = parseInput(readFile(input_file))
local start_point = {x = 1, y = 1}
local vertices = {start_point}
-- work through the dig plan and record the vertices
while next(dig_plan) do
  local instruction = table.remove(dig_plan, 1)
  local end_point = process_instruction(start_point, instruction)
  table.insert(vertices, end_point)
  start_point = end_point
end

print("Part 2 answer: " .. calculateArea(vertices))
